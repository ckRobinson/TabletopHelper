# Project Overview
This project is a work in progress iOS app designed to help Dungeon Masters run tabletop role playing games. It is meant as an exploration into the Swift programming language for CSC690 at San Francisco State University for the fall 2021 semester. It's goal is to demonstrate the knowledge gained in the class by building an app using Swift. The application is built using Swift5 and SwiftUI.

<br>

---
---

<br>

# Scope 

### Priority 1 - Must Have
 
- Quick Dice Roller
- Name Generator system
- Random Generator system

### Priority 2 - Nice to Have

- User customization of name generators and random generators
- Displaying a digital representation of the rolled die on the device screen

### Priority 3 - Optional

- Augmented reality version of the dice roller

<br>

---
---

<br>

# Current State
Currently the application has all priority 1 features implemented, expanded below, for the generators the only thing missing would be more content. But as that is mostly a task of data collection for the generators to use I am pushing that back to focus on higher priority items. 

---

## Dice Roller
The dice roller works as intended, it is a quick access panel with a floating menu available from almost every screen. It can be used easily durring a gaming session or during prep to quickly roll some dice to determine an outcome.

#### Possible Improvments

- Add another item that can roll a custom sized die. 
- Add the option of rolling multiple dice at the same time.

--- 

## Name Generators
The name generators are built using an implementation of Markov Chains, using a supplied set of names to create a state table. When generating a name it will look at the current state of the name and then compare to the state table to pick the next valid character to add to the name. This implementation uses 2nd order transitions to compare the previous two characters rather than just the most recent character. This makes the generation less random and creates more believeable naemes. The data set used to build the state table for the current two generators is taken from the Guild Wars 2 wiki.

#### Possible Improvments

- Add a 3rd order generator to look at the previous 3 characters.
- Make the generation order selectable by users.

--- 

## Random Generators
The current random generators are designed to load their data from a formatted CSV file. It uses a string such as "[[this]] is replaced by [[somevalue]]" and for every bracketed item there should be a table of possible options. This can then be used to generate complex sentences where there could be millions of different outcomes just bassed of a few tables.

#### Possible Improvments

- Implement quick tables for when only 1 or 2 items need to be selected from rather than creating an entirely new column in the CSV file.
- Add custom weights to the data items to prioritize some options over others.
- Add an option to "roll" a die on the table rather than selecting by weight.
- Add an option to have modifiers to the "roll" option, allowing for previously generated items to affect future items.

<br>

--- 
--- 
 
<br>

# Future development
I plan to keep working on this project in the future to implement the improvements above as well as adding in the P2 features.