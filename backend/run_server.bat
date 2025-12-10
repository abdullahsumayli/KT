@echo off
cd /d D:\KT\backend
set PYTHONPATH=D:\KT\backend
call .venv\Scripts\activate.bat
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
pause
