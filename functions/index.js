/* eslint-disable max-len */
const functions = require("firebase-functions");
const {Deepgram} = require("@deepgram/sdk");
const {Buffer} = require("buffer");
const nodemailer = require("nodemailer");
const {PDFDocument, StandardFonts} = require("pdf-lib");

// The API key we created in step 3
const deepgramApiKey = "9a6a80fb8770b12908165781281db74b3ff0703d";

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//

exports.sendTranscribe = functions.https.onCall(async (payload) => {
  // Initializes the Deepgram SDK
  const deepgram = new Deepgram(deepgramApiKey);

  // Decode the base64-encoded string into a buffer
  const buffer = Buffer.from(payload.audio.base64String, "base64");
  const mimetype = payload.audio.mimetype;

  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: payload.from.email,
      pass: payload.from.password,
    },
    tls: {
      rejectUnauthorized: false,
      // cipher: SSLv3 tried
    },
  });

  deepgram.transcription.preRecorded(
      {buffer: buffer, mimetype},
      // eslint-disable-next-line max-len
      {punctuate: true, diarize: true, utterances: true, utt_split: 1.0, model: "general", language: "nl", tier: "enhanced"},
      // {punctuate: true, diarize: true, utterances: true, utt_split: 1.0, model: "general", detect_language: true, language: "nl", tier: "enhanced"},
  ).then(async (transcription) => {
    let currentSpeaker = 0;

    let transcribeText = "";
    let sentence = "";
    currentSpeaker = 0;

    const utterances = transcription.results.utterances;
    utterances.forEach((transcript, index) => {
      if (transcript.speaker != currentSpeaker) {
        transcribeText += `Speaker ${currentSpeaker}: ${sentence}\n`;
        sentence = "";
        currentSpeaker = transcript.speaker;
      } else if (index == utterances.length - 1) {
        // Add the last words to the current sentence
        sentence += `${transcript.transcript} `;
        transcribeText += `Speaker ${currentSpeaker}: ${sentence}\n`;
        sentence = "";
        currentSpeaker = transcript.speaker;
      }

      // Add the words to the current sentence
      sentence += `${transcript.transcript} `;

      // transcribeText += `Speaker ${transcript.speaker}: `;
      // transcribeText += transcript.transcript;
      // transcribeText += `\n`;
    });

    // Write the last sentence to the file
    console.log("////////////////////////");
    console.log("Transcribe Complete");
    console.log("////////////////////////");

    // ///////////////////////////////////////////////////////////////////////////////////
    const pdfDoc = await PDFDocument.create();
    const helveticaBold = await pdfDoc.embedFont(StandardFonts.HelveticaBold);
    const helvetica = await pdfDoc.embedFont(StandardFonts.Helvetica);

    const title = "Transcribed File";

    const titleSize = 24;
    const bodySize = 12;
    const titleMarginTop = 50;
    const bodyMarginTop = 20;

    // Add first page
    const firstPage = pdfDoc.addPage();
    // eslint-disable-next-line no-unused-vars
    const {width, height} = firstPage.getSize();

    const textWidthTitle = helvetica.widthOfTextAtSize(title, titleSize);

    // Add title
    firstPage.drawText(title, {
      x: (width / 2 - textWidthTitle / 2),
      y: firstPage.getHeight() - titleMarginTop,
      size: titleSize,
      font: helveticaBold,
      // color: '#000000',
    });

    // Add body text
    firstPage.drawText(transcribeText, {
      x: 50,
      y: firstPage.getHeight() - titleMarginTop - bodyMarginTop - bodySize,
      size: bodySize,
      font: helvetica,
      // color: '#000000',
    });

    const pdfBytes = await pdfDoc.save();
    // ///////////////////////////////////////////////////////////////////////////////////
    const subject = payload.to.name + ": Here is the latest transcribed";
    const mailOptions = {
      from: payload.from.email,
      to: payload.to.email,
      subject: subject,
      text: "Please find attached transcribed file as pdf.",
      attachments: [
        {
          filename: `${payload.number}.pdf`,
          content: pdfBytes,
          contentType: "application/pdf",
        },
      ],
    };

    // Send the email using the transporter object
    transporter.sendMail(mailOptions)
        .then(() => {
          console.log(`Email sent to ${mailOptions.to}`);
          return {success: true};
        })
        .catch((error) => {
          console.error(`Error sending email to ${mailOptions.to}`, error);
          return {success: false, error: error};
        });
  }).catch((error) => {
    console.log(error);
    return {success: false, error: error};
  });

  return {success: true};
});
