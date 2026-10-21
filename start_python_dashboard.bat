@echo off
title Hanshans Python Projektboard & KI
echo ============================================================
echo   HANDWERKERHAUS HANSHANS - PYTHON PROJEKTBOARD (STREAMLIT)
echo ============================================================
echo.
cd /d "%~dp0"
echo Starte Streamlit Dashboard im Browser...
python -m streamlit run app.py
pause
