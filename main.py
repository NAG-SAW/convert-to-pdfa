from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
import uuid
import subprocess
import os
import asyncio
import time

# Local folders
processed_dir = "processed"
temp_dir = "temp_files"
os.makedirs(processed_dir, exist_ok=True)
os.makedirs(temp_dir, exist_ok=True)

# Cleanup files background process
async def cleanup_old_files():
    while True:
        await asyncio.sleep(3600)  # Check every hour
        try:
            now = time.time()
            cutoff = now - 12 * 3600  # 12 hours ago
            for filename in os.listdir(processed_dir):
                filepath = os.path.join(processed_dir, filename)
                if os.path.isfile(filepath) and os.path.getmtime(filepath) < cutoff:
                    os.remove(filepath)
                    print(f"Removed old file: {filename}")
        except Exception as e:
            print(f"Error during cleanup: {e}")

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Start the cleanup background task
    cleanup_task = asyncio.create_task(cleanup_old_files())
    yield
    # Cancel the task on shutdown
    cleanup_task.cancel()
    try:
        await cleanup_task
    except asyncio.CancelledError:
        pass


# Backend
app = FastAPI(lifespan=lifespan)

@app.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    if not file.filename.lower().endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Only PDF files allowed")
    file_id = str(uuid.uuid4())
    
    try:
        # Save uploaded file temporarily
        temp_path = os.path.join(temp_dir, f"{file_id}.pdf")
        with open(temp_path, "wb") as f:
            content = await file.read()
            f.write(content)
        
        # Call external script
        output_path = os.path.join(processed_dir, f"{file_id}.pdf")

        result = subprocess.run(['bash', 'convert_to_pdfa.sh', temp_path, output_path], timeout=120)
        if result.returncode != 0:
            raise HTTPException(status_code=500, detail=f"Processing failed")
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=500, detail=f"Processing timed out")
    except:
        raise HTTPException(status_code=500, detail=f"Processing failed")
    finally:
        # Clean up temp file
        os.remove(temp_path)

    return {"uuid": file_id}

# Mount static files to serve processed PDFs
app.mount("/files", StaticFiles(directory=processed_dir), name="files")