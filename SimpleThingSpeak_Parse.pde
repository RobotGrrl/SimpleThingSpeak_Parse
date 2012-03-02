/*

  A bare-bones example of receiving data from the cloud for
  various ThingSpeak implementations, like MyRobots
  
  We use the JSON library to grab the data and parse it, you
  can get it here:
  https://github.com/agoransson/JSON-processing/downloads
  
  By default all of the request URLs include your robot key.
  You can also add optional parameters for fine tuned details,
  for that you can read the API documentation:
  http://www.myrobots.com/wiki/API

  If you want to look at the structure of a JSON file before
  trying to parse it (this is a really good idea), this is a 
  good website:
  http://jsonviewer.stack.hu/
  
  There are three main points in this sketch-
  1. entire robot feed
  2. specific field feed
  3. last entry in robot feed
  
  For more information:
  ThingSpeak: http://thingspeak.com
  MyRobots: http://myrobots.com
  
  By RobotGrrl
  robotgrrl.com Feb 29, 2012 (leap year!)

*/

/*

MyRobots JSON format

channel
- created_at (str)
- description (str)
- field1...8 (str)
- id (int)
- last_entry_id (int)
- name (str)
- updated_at (str)

feeds
- (your entry int here)
-- created_at (str)
-- entry_id (int)
-- field1...8 (str)

*/

import org.json.*;

String ROBOT_ID = "77"; // your robot id
String APIKEY = "15A0D2B06EFD4A36"; // your api key
String SERVER = "bots.myrobots.com"; // MyRobots or ThingSpeak
String BASE_URL = ("http://" + SERVER + "/channels/" + ROBOT_ID + "/feed.json?key=");

int FREQ = 5; // refresh every 5s

int sec_0 = 88; // previous second, silly value
int sec; // time counter

void setup() {
  size(200, 200);
  frameRate(60);
  println("Hi!");
  
  // example, get random stuffs, print it out
  String robotName = (String)getChannelValue("name");
  String creationDate = (String)getChannelValue("created_at");
  int lastEntry = ((Integer)getChannelValue("last_entry_id")).intValue();
  int feedsNum = getFeedLength();
  String lastField1 = (String)getFeedValue("field1", (feedsNum-1));
  
  println("\nHey! Did you know that " + robotName + ", aka coolest robot in the world was created on MyRobots on " + creationDate + "?");
  println("It's last field1 value that it sent (entry #" + lastEntry + " by the way) was: " + lastField1 + ". Cool!\n");
  
}

void draw() {
  
  sec = second();

  if (sec%FREQ == 0 && sec_0 != sec) {
    println("\n\nding!");
    sec_0 = sec;
    
    getLastEntryValue("field1");
    
    println("done\n");
  } 
  else {
    if (sec != sec_0) {
      print(sec + " ");
      sec_0 = sec;
    }
  }
  
}


// --- entire robot feed parsers

Object getChannelValue(String valueName) {
  
  println("getting channel-" + valueName);
  
  Object result;
  
  // Get the JSON formatted response
  String response = loadStrings( BASE_URL + APIKEY )[0];
 
  // Make sure we got a response.
  if (response != null) {
    
    // Initialize the JSONObject for the response
    JSONObject root = new JSONObject(response);

    // Get the "channel" JSONObject
    JSONObject channel = root.getJSONObject("channel");
    
    // Get the given name value from the channel object
    result = channel.get(valueName);
    
    // Print the result, here you can do whatever you want with it
    println(valueName + ": " + result);
    return result;
    
  }
  
  return null;
  
}

Object getFeedValue(String valueName, int feedEntry) {
  
  println("getting feed-" + valueName + "-" + feedEntry);
  
  Object result;
  
  // Get the JSON formatted response
  String response = loadStrings( BASE_URL + APIKEY )[0];
 
  // Make sure we got a response.
  if (response != null) {
    
    // Initialize the JSONObject for the response
    JSONObject root = new JSONObject(response);

    // Get the feeds array
    JSONArray feeds = root.getJSONArray("feeds");

    // Get the entry (index) we're looking for
    JSONObject entry;
    try {
    entry = (JSONObject)feeds.get(feedEntry);
    } catch(JSONException e) {
      println(e);
      return null;
    }
    
    // Get the given name value from the entry object
    result = entry.get(valueName);
    
    // Print the result, here you can do whatever you want with it
    println(valueName + ": " + result);
    return result;
    
  }
  
  return null;
  
}

int getFeedLength() {
  
  println("getting feed length");
  
  int result;
  
  // Get the JSON formatted response
  String response = loadStrings( BASE_URL + APIKEY )[0];
 
  // Make sure we got a response.
  if (response != null) {
    
    // Initialize the JSONObject for the response
    JSONObject root = new JSONObject(response);

    // Get the feeds array
    JSONArray feeds = root.getJSONArray("feeds");

    result = feeds.length();
    
    // Print the result, here you can do whatever you want with it
    println("number of feed entries: " + result);
    return result;
    
  }
  
  return 0;
  
}


// ---


// --- field feed

Object getSpecificFeedValue(String fieldName, String valueName, int feedEntry) {
  
  println("getting " + fieldName + "-" + valueName + "-" + feedEntry);
  
  Object result;
  
  String fieldFeedURL = ("http://" + SERVER + "/channels/" + ROBOT_ID + "/field/" + fieldName + ".json?key=");
  
  // Get the JSON formatted response
  String response = loadStrings( fieldFeedURL + APIKEY )[0];
 
  // Make sure we got a response.
  if (response != null) {
    
    // Initialize the JSONObject for the response
    JSONObject root = new JSONObject(response);

    // Get the feeds array
    JSONArray feeds = root.getJSONArray("feeds");

    // Get the entry (index) we're looking for
    JSONObject entry;
    try {
    entry = (JSONObject)feeds.get(feedEntry);
    } catch(JSONException e) {
      println(e);
      return null;
    }
    
    // Get the given name value from the entry object
    result = entry.get(valueName);
    
    // Print the result, here you can do whatever you want with it
    println(valueName + ": " + result);
    return result;
    
  }
  
  return null;
  
}

// ---


// --- last entry in robot feed parser

Object getLastEntryValue(String valueName) {
  
  println("getting feed-" + valueName);
  
  Object result;
  
  String lastEntryURL = ("http://" + SERVER + "/channels/" + ROBOT_ID + "/feed/last.json?key=");
  
  // Get the JSON formatted response
  String response = loadStrings( lastEntryURL + APIKEY )[0];
 
  // Make sure we got a response.
  if (response != null) {
    
    // Initialize the JSONObject for the response
    JSONObject feeds = new JSONObject(response);

    // Get the entry
    result = feeds.get(valueName);
    
    // Print the result, here you can do whatever you want with it
    println(valueName + ": " + result);
    return result;
    
  }
  
  return null;
  
}

// ---

