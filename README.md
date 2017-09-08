# MyCalendar
A Swift 3 project to show and edit the events in the user's Calendar

## Description
This calendar is a learning project for myself to understand how to use Apple's EventKit API and JTApple Calendar together to create an interactive calendar/agenda view.Originally, I was building this in my fork of Andrew Bancroft's EventTracker, but I decided to separate it. 

## Functionality
MyCalendar has the following functions/features:
+ self-defined colors and buttons
+ connects to user's calendars and gets/interacts with the calendar with title "Calendar" - note that the other two default calendars, Birthdays and US Holidays, are not editable. 
+ uses JTAppleCalendar (Version 7.0.6) to:
  + include a scrolling horizontal monthly calendar
  + include a today button to return to today
  + highlight (with a dot) days with events
  + include a + button to add a new event
+ shows an agenda view for each day with a list of events
  + agenda items can be edited by clicking on the event
  + agenda items show the title, start time, and stop time.

TODO
+ show a changing image based on the event
+ allow user to add/edit agenda events from the calendar view by clicking on a button 

## Compatibility
This version works with Swift 3 and Xcode 8.3.3
