# Speak Like Khajiit - An Elder Scrolls Online Addon

## Context for Non-Elder Scrolls Players
This addon addresses a key immersion gap in Elder Scrolls Online. In the game's lore, Khajiit—a race of cat-like humanoids from the desert province of Elsweyr—speak with distinctive linguistic patterns, notably referring to themselves in the third person (e.g., "This one needs help" rather than "I need help"). Despite this rich cultural background, the base game presents all player dialogue options in standard English regardless of your character's race.

As someone passionate about creating deeply immersive gaming experiences, I developed this addon to bridge that gap between lore and gameplay mechanics.

## Features for Players
* **Authentic Khajiit Speech Patterns** Transform your character's dialogue options with questions are phrased in the distinctive Khajiit interrogative style
* **Self-Reference Options:** Choose between "this one," your character name, or "Khajiit" as your preferred self-reference style

## Technical Overview
This addon uses a sophisticated linguistic processing system:
* **Event-driven architecture** hooks into the game's dialogue system without performance impact
* **Complex Pronoun Resolution:** Intelligently handles multiple self-references within single sentences to maintain grammatical coherence. (e.g., "I was minding my business..." to "This one was minding his business...")
* **Contextual Grammar Adaptation:** Transforms verb conjugations and syntactic structures to match Khajiit speech patterns

## Implementation Highlights
* **Memory Persistence** Utilises ZO_SavedVars for configuration management whilst handling version migration.
* **Specialized linguistic dictionary** preserves meaning while altering syntax

This project represents my commitment to creating thoughtful, detail-oriented systems that enhance user experiences while respecting established narrative elements.

## Support

If you find this addon useful, consider supporting its development:
* [Ko-fi](https://Ko-fi.com/yfnatey)
* [PayPal](https://paypal.me/yfnatey)