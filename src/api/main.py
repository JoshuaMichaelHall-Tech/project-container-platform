#\!/usr/bin/env python3
"""
Container Security Platform API

This is the main entry point for the Container Security Platform API.
It defines the FastAPI application and includes all routes.
"""

import os
import logging
import uvicorn
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.getLevelName(os.getenv("LOG_LEVEL", "INFO")),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

# Create FastAPI application
app = FastAPI(
    title="Container Security Platform API",
    description="API for the Container Security Platform for Financial Services",
    version="0.1.0",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, this should be restricted
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health check endpoint
@app.get("/health", tags=["health"])
async def health_check():
    """
    Health check endpoint to verify the API is running.
    """
    return {"status": "healthy"}

# Include routers
# Note: In a real application, routes would be defined in separate modules
# and included here. For this example, we'll define a simple route.

@app.get("/", tags=["root"])
async def root():
    """
    Root endpoint returning basic API information.
    """
    return {
        "name": "Container Security Platform API",
        "version": "0.1.0",
        "status": "planning",
        "documentation": "/docs",
    }

# Main entrypoint
if __name__ == "__main__":
    host = os.getenv("API_HOST", "0.0.0.0")
    port = int(os.getenv("API_PORT", "8000"))
    
    logger.info(f"Starting Container Security Platform API on {host}:{port}")
    
    uvicorn.run("main:app", host=host, port=port, reload=True)
EOF < /dev/null