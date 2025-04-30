import requests
from bs4 import BeautifulSoup
import openai  # For GPT-based response

# Step 1: Scrape the website
url = "https://www.takuwa.co.jp/en/"
response = requests.get(url)
soup = BeautifulSoup(response.text, "html.parser")

# Step 2: Extract all text from the website
texts = soup.get_text()

# Step 3: Define a function to interact with GPT model
openai.api_key = 'your-openai-api-key'  # Replace with your OpenAI API key

def get_answer_from_gpt(query, context):
    response = openai.Completion.create(
        engine="text-davinci-003",  # You can use other engines if you prefer
        prompt=f"Given the following information:\n\n{context}\n\nAnswer the question: {query}",
        max_tokens=150
    )
    return response.choices[0].text.strip()

# Step 4: Example of asking the chatbot a question
query = "What is Takuwa?"
answer = get_answer_from_gpt(query, texts)

print(f"Chatbot Answer: {answer}")
