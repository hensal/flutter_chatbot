const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const fs = require("fs");
const app = express();
const PORT = 3001;

// Middleware
app.use(bodyParser.json());
app.use(cors());

// Load chatbot data
const dataFilePath = "chatbot_data.json";
let qaData = [];
fs.readFile(dataFilePath, "utf8", (err, data) => {
  if (err) {
    console.error("Error reading chatbot data:", err);
  } else {
    qaData = JSON.parse(data);
    console.log("Chatbot data loaded successfully.");
  }
});

// Function to calculate Levenshtein Distance (Edit Distance)
function getEditDistance(a, b) {
  const matrix = Array.from({ length: a.length + 1 }, () =>
    Array(b.length + 1).fill(0)
  );
  for (let i = 0; i <= a.length; i++) matrix[i][0] = i;
  for (let j = 0; j <= b.length; j++) matrix[0][j] = j;

  for (let i = 1; i <= a.length; i++) {
    for (let j = 1; j <= b.length; j++) {
      matrix[i][j] =
        a[i - 1] === b[j - 1]
          ? matrix[i - 1][j - 1]
          : Math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + 1);
    }
  }
  return matrix[a.length][b.length];
}

// Endpoint for chatbot interaction
app.post("/chat", (req, res) => {
  const userMessage = req.body.message?.toLowerCase();
  console.log("Received message: ", userMessage); // Log the received message
  if (!userMessage) {
    return res.status(400).json({ response: "Invalid input." });
  }
  // Handle greetings (same as before)
  const greetingKeywords = ["h", "hello", "huh", "hi", "hey"];
  if (greetingKeywords.some((keyword) => userMessage.startsWith(keyword))) {
    return res.json({ response: "Hi! How can I assist you today?" });
  }

  // Handle confirmation-related inputs (same as before)
  const confirmationKeywords = ["y", "yes", "yah", "ye", "yeah", "yup"];
  if (confirmationKeywords.some((keyword) => userMessage.startsWith(keyword))) {
    if (lastSuggestion) {
      const confirmedAnswer = qaData.find(
        (item) => item.Question.toLowerCase() === lastSuggestion.toLowerCase()
      );
      if (confirmedAnswer) {
        lastSuggestion = null; // Reset suggestion after confirmation
        return res.json({ response: confirmedAnswer.Answer });
      }
    }
    return res.json({
      response: "I'm not sure what you're confirming. Could you clarify?",
    });
  }

  // Handle negative inputs (same as before)
  const negativeKeywords = ["n", "no", "nah", "nope", "nahh", "noh", "nap"];
  if (negativeKeywords.some((keyword) => userMessage.startsWith(keyword))) {
    const nearestMatch = qaData.reduce((closest, current) => {
      const distance = getEditDistance(userMessage, current.Question.toLowerCase());
      return distance < closest.distance
        ? { question: current.Question, distance }
        : closest;
    }, { question: null, distance: Infinity });
    return res.json({
      //response: `It seems you're saying no. Did you mean: ${nearestMatch.question}?`,
      response: `It seems you're saying no. Could you clarify?`,
    });
  }

  // Check for exact match (same as before)
  const exactMatch = qaData.find(
    (item) => userMessage === item.Question.toLowerCase()
  );
  if (exactMatch) {
    return res.json({ response: exactMatch.Answer });
  }
  // Check for partial matches (suggestion)
  const suggestions = qaData.filter((item) =>
    item.Question.toLowerCase().includes(userMessage)
  );
  // If there are partial matches, suggest the closest one
  if (suggestions.length > 0) {
    lastSuggestion = suggestions[0].Question; // Save the first suggestion
    return res.json({
      response: `Did you mean: "${lastSuggestion}"?`,
    });
  }
  // If no matches at all, ask the user to confirm
  res.json({
    response: "Sorry, I don't understand that. Please confirm your query!",
  });
});

// Add a simple GET route for the root path
app.get("/", (req, res) => {
  res.send("Welcome to the Chatbot API! Use the POST /chat endpoint to interact.");
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
