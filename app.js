let expirationDate = null;

async function loadData(){

try{

const response = await fetch(
'https://ubapi.earthlink.iq/api/user/GetUserDataAr'
);

const data = await response.json();

document.getElementById('name').innerText =
data.fullName.value;

document.getElementById('status').innerText =
data.accountStatus.value;

document.getElementById('package').innerText =
data.accountName.value;

document.getElementById('price').innerText =
data.accountPrice.value;

document.getElementById('username').innerText =
data.userID.value;

document.getElementById('ip').innerText =
data.userIP.value;

document.getElementById('agent').innerText =
data.agentName.value;

document.getElementById('expire').innerText =
data.accountExpirationDate.value;

let date =
data.accountExpirationDate.value
.split(" ")[0];

let p = date.split("/");

expirationDate =
new Date(
p[2],
p[1]-1,
p[0]
);

}catch(error){

console.log(error);

}

}

setInterval(()=>{

if(!expirationDate)return;

let now = new Date();

let distance =
expirationDate - now;

if(distance <= 0)return;

let days =
Math.floor(distance/(1000*60*60*24));

let hours =
Math.floor((distance%(1000*60*60*24))/(1000*60*60));

let minutes =
Math.floor((distance%(1000*60*60))/(1000*60));

let seconds =
Math.floor((distance%(1000*60))/1000);

document.getElementById('days').innerText = days;
document.getElementById('hours').innerText = hours;
document.getElementById('minutes').innerText = minutes;
document.getElementById('seconds').innerText = seconds;

},1000);

loadData();
