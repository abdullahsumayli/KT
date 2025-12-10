@echo off
cd /d D:\KT\backend
call .venv\Scripts\activate.bat
uvicorn app.main:app --reload
