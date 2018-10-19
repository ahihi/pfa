# midibloom

audiovisual live performance prototype  

![screenshot](https://static.foldplop.com/misc/midibloom.png)

## how to run

(designed for Reason on macOS — adapt for other environments as needed)

1. enable the IAC MIDI driver in Audio/MIDI Setup and make sure it has at least one port with an input and output connector
2. open `midibloom.reason` and set the output of the three External MIDI Instrument devices to your IAC bus
3. ensure that the IAC bus isn't being used as an input in Reason, or you'll have a feedback loop!
4. open `midibloom.pde` and set the `midi_device` variable to the name of your IAC bus
5. play the song and tweak the CC knobs on the three Combinators

## inputs

the Processing sketch listens to the following MIDI inputs:

### rings

- notes 48-71 (C3-B4) on channel 1
- control change 30 & 31 on any channel

### rays

- notes on channel 2
- control change 32 & 33 on any channel

### petals

- notes on channel 3 — designed for notes 26 (D1) and up
- control change 34 & 35 on any channel

you'll need to turn up CC 30/32/34 to see anything!
