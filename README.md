# PDF Convert API

A FastAPI application for uploading PDF files, processing them with an external script, and serving the processed files.

## Features

- Upload PDF files via POST /upload endpoint
- Returns a UUID for the uploaded file
- External script processes the file and places output in `processed/` folder
- Serve processed files via static file serving at /files/

## Requirements

- Python 3.8+
- Dependencies listed in `requirements.txt`

## Installation

1. Create a virtual environment:
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

## Running the Application

Run the FastAPI server:
```bash
uvicorn main:app --reload
```

The API will be available at `http://127.0.0.1:8000`

## Docker Deployment

For production deployment using Docker:

1. Build the image:
   ```bash
   docker build -t pdf-convert .
   ```

2. Run the container:
   ```bash
   docker run -p 8000:8000 pdf-convert
   ```

The API will be available at `http://localhost:8000`

## API Endpoints

### POST /upload
Upload a PDF file.

- **Request**: Multipart form with `file` field containing the PDF.
- **Response**: JSON with `uuid` key.

Example:
```bash
curl -X POST "http://127.0.0.1:8000/upload" -F "file=@example.pdf"
```

### GET /files/{filename}
Serve a processed file.

- **Path Parameter**: `filename` - the UUID.pdf file.

Example:
```bash
curl "http://127.0.0.1:8000/files/<uuid>.pdf"
```
