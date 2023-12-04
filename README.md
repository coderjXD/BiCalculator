# BiCalculator
This repository is used as the assignment for a technical exam of *Aha AI*.

# Notice
1. Supports dark mode. If the color scheme is not as the demo image, try to toggle the dark mode.
2. Supports continuous calculation, but the calculating sequence is according to the input sequence rather than the arithmetic associate rules.
3. It is not clear what the *DEL* button should do in the exam asset, so I asume it is used for clear the last tranported number. e.g., the number on the left screen is 10 and the number on the right is 12 (`12+` on the go). When the *→* button is pressed, the *10* is transported to the right screen, the right screen becomes *10* and the state is `12+10`. Now the *DEL* clicked, the state of the right flips back to `12+`.
Only the transported number is `DEL`eted, because the button is in the middle rather than in every single calculator. If there is no transported number at the end of both states, nothing will happen.