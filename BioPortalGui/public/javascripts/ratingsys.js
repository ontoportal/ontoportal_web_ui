/*
Author: Addam M. Driver
Date: 10/31/2006
*/

var sMax;	// Isthe maximum number of stars
var holder; // Is the holding pattern for clicked state
var preSet =[]; // Is the PreSet value onces a selection has been made
var rated =[];

// Rollover for image Stars //
function rating(num){
	sMax = 0;	// Isthe maximum number of stars
	for(n=0; n<num.parentNode.childNodes.length; n++){
		if(num.parentNode.childNodes[n].nodeName == "A"){
			sMax++;	
		}
	}
	
	firsthalf = num.id.split("_")[0];


		s = num.id.split("_")[1]; // Get the selected star
		a = 0;
		for(i=1; i<=sMax; i++){		
			if(i<=s){
				document.getElementById(firsthalf+"_"+i).className = "on";
		//		document.getElementById("rateStatus").innerHTML = num.title;	
				holder = a+1;
				a++;
			}else{
				document.getElementById(firsthalf+"_"+i).className = "";
			}
		}

}

// For when you roll out of the the whole thing //
function off(me){
    firsthalf=me.id.split("_")[0]
    

		if(!preSet[firsthalf]){	

		    
		    
			for(i=1; i<=sMax; i++){		
				document.getElementById(firsthalf+"_"+i).className = "";
		//		document.getElementById("rateStatus").innerHTML = me.parentNode.title;
			}
		}else{
			rating(preSet[firsthalf]);
//			document.getElementById("rateStatus").innerHTML = document.getElementById("ratingSaved").innerHTML;
		}

}

// When you actually rate something //
function rateIt(me){
    
	firsthalf=me.id.split("_")[0]

//		document.getElementById("rateStatus").innerHTML = document.getElementById("ratingSaved").innerHTML + " :: "+me.title;
		preSet[firsthalf] = me;
		rated[firsthalf]=1;
		sendRate(me);
		rating(me);

}

// Send the rating information somewhere using Ajax or something like that.
function sendRate(sel){
    firsthalf=sel.id.split("_")[0]
    value = sel.id.split("_")[1]
    document.getElementById(firsthalf).value = value
}

