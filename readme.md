To run this app:
Backend : In the Backend root folder
uvicorn main:app --reload --host 0.0.0.0 --port 8000 

Frontend :In the frontend root folder
adb reverse tcp:8000 tcp:8000
flutter run

go to services.msc if postgres service is stopped start it

