# chilelog
powerlifting training log shiny web app

## My plan on how this is going to work

Instead of a proper database solution we are going to use google sheets (lmao).
The idea is that google sheets is going to work as our database providing:
1. The training plan for each user
2. A sheet to store all users logs
Then the shiny web app will use 1 and 2 to provide the user a simple way to log their training.
User will specify:
- Current block (training day)
- Current cycle (probably this will be automatic)
Web UI will show:
- All the exercises for that block
- A space to input lifted weights for each exercise
- A "Log" button to log
A "log action" should be super fast

In the future, with a working log app, the idea is for the app to give training recommendation, building training cycles, etc.

