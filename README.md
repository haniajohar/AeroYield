# AeroYield

Satellite + AI-driven farm intelligence platform for smallholder farmers in Pakistan.

## Repository Structure

- **backend/** - FastAPI backend with ML crop-stress prediction, NASA POWER weather integration, and bilingual (EN/UR) advisories
- **web/** - Next.js admin panel (coming soon)

## Quick Start (Backend)

`ash
cd backend
python -m venv .venv
pip install -r requirements.txt
python generate_mock_model.py
uvicorn app.main:app --reload --port 8000
`

Then open http://localhost:8000/docs
