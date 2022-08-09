const app = require('express')();
const clients = 10;
const seed = 1277435
let connected = 0;
const command = `masscan --banners 0.0.0.0/0  -p25565 --rate=100 --source-port 61000 --resume paused.conf -oJ log.json --excludefile data/exclude.conf --seed ${seed}`;
app.use((req,res) =>{
	if (connected >= clients) {
		res.status(400).end();
		console.error("Too many connections...");
	} else {
		connected++;
		res.send(command+` --shards ${connected}/${clients}`).status(200).end();
	}
});
app.listen(8080);
