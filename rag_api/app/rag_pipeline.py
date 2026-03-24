from qdrant_client import QdrantClient
from sentence_transformers import SentenceTransformer
import requests
from qdrant_client.models import ScoredPoint
from qdrant_client.models import VectorParams, Distance, ScoredPoint


# -----------------------------
# Config
# -----------------------------
QDRANT_HOST = "http://localhost:6333"
OLLAMA_URL = "http://localhost:11434/api/generate"
COLLECTION_NAME = "rag_collection"

# -----------------------------
# Initialize clients
# -----------------------------
qdrant = QdrantClient(url=QDRANT_HOST)
embedder = SentenceTransformer("all-MiniLM-L6-v2")

# -----------------------------
# Sample documents
# -----------------------------
documents = [
    "Retrieval-Augmented Generation (RAG) combines retrieval with generation.",
    "Qdrant is a vector database used for similarity search.",
    "Ollama allows running LLMs locally.",
]

# -----------------------------
# Create collection
# -----------------------------
def create_collection():
    # Delete if exists, then create fresh
    existing = [c.name for c in qdrant.get_collections().collections]
    if COLLECTION_NAME in existing:
        qdrant.delete_collection(COLLECTION_NAME)
    
    qdrant.create_collection(
        collection_name=COLLECTION_NAME,
        vectors_config=VectorParams(size=384, distance=Distance.COSINE)
    )

# -----------------------------
# Insert documents
# -----------------------------
def insert_documents():
    vectors = embedder.encode(documents).tolist()

    qdrant.upsert(
        collection_name=COLLECTION_NAME,
        points=[
            {
                "id": i,
                "vector": vectors[i],
                "payload": {"text": documents[i]},
            }
            for i in range(len(documents))
        ],
    )

# -----------------------------
# Query RAG
# -----------------------------
def query_rag(query):
    query_vector = embedder.encode(query).tolist()
    hits = qdrant.query_points(
        collection_name=COLLECTION_NAME,
        query=query_vector,
        limit=2
    ).points

    context = "\n".join([hit.payload["text"] for hit in hits])

    prompt = f"""
    Answer the question using the context below.

    Context:
    {context}

    Question:
    {query}
    """

    response = requests.post(
        OLLAMA_URL,
        json={
            "model": "llama3",
            "prompt": prompt,
            "stream": False,
        },
    )
    data = response.json()
    if "response" not in data:
        raise ValueError(f"Unexpected Ollama response: {data}")

    return data["response"]

# -----------------------------
# Run pipeline
# -----------------------------
if __name__ == "__main__":
    create_collection()
    insert_documents()

    query = "What is RAG?"
    answer = query_rag(query)

    print("\nAnswer:\n", answer)