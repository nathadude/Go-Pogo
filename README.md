# Go Pogo!

### *“Go pogo, go pogo, go pogo!” ad infinitum.*

Started from a literal dream chant, **Go Pogo!** is a physics-arcade prototype focusing on high-precision spring mechanics and "hype-based" progression. No canned jump animations here—everything is driven by a custom Hooke's Law integration.

## 🛠 The Physics (The "How")

The goal was to move away from binary "Press to Jump" logic and create a pogo stick that actually feels like a mechanical spring under load.

* **Hooke’s Law Implementation:** Jump force is calculated based on a dynamic spring constant and a compression distance recorded from player input.
* **Logarithmic Compression:** To simulate spring stiffness,  increases logarithmically. It ramps up fast initially but requires precise timing to hit that last 10% before the spring "buckles."
* **The Buckle Mechanic:** If you hold the compression too long, the spring slips. This forces a decay in , punishing "camping" on the charge and rewarding twitch release.
* **Weighted  Decay:** Passive bounces (landing without charging) result in a loss of spring stiffness. The decay is weighted by impact velocity—the harder you hit, the more "residual hype" (momentum) you keep.

## 🚀 Current Build Status

* **Character Controller:** Custom `CharacterBody2D` with gravity integration and a "slam" mechanic that converts fall velocity into initial spring compression.
* **Modular Trick System:** A standalone `TrickManager` node that spies on parent rotation to track 360-degree flips without bloating the physics script.
* **Dynamic  Rewards:** Accuracy-based rewards. Releasing the spring closer to  grants a permanent (until decay) increase to the spring constant.
* **Procedural Squash/Stretch:** Visual feedback is tied directly to the  compression value—the player sprite physically flattens as the potential energy builds.

## 🎯 The Parking Lot (Future Scope)

* **The Chant Engine:** A dynamic audio layer. As  increases and tricks chain, the dream-inspired "Go Pogo!" chant fades in, starting soft and hitting a Mario-style "Starman" hype level at max combos.
* **Hype-Gated Progression:** Level design where platforms are height-gated. You can't just jump to the end; you have to "build the hype" (increase ) through consecutive perfect bounces to reach higher elevations.
* **Trick UI:** Feedback system for release timing:
* `< 80x`: Early...
* `81-95x`: Great!
* `96-99x`: Excellent!
* `100x`: **PERFECT**


* **Visual Polish:** Adding spring sparks at max  and particle trails when the chant triggers.

---

## 👨‍💻 Developed By

**NathaDUDE**
