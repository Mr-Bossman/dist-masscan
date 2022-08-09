const app = require('express')();
const clients = 10;
const seed = 1277435
let connected = 0;
const command = `masscan --banners 0.0.0.0/0  -p25565 --rate=100 --source-port 61000 --excludefile exclude.conf --seed ${seed}`;
app.use((req,res) =>{
	if (req.headers.pass === undefined || req.headers.pass !== "carl") {
		res.status(400).end();
		console.error(`${req.headers['x-forwarded-for'] || req.socket.remoteAddress} tried to connect using ${JSON.stringify(req.headers)} but is not allowed...`);
		return;
	}
	if (connected >= clients) {
		res.status(400).end();
		console.error("Too many connections...");
	} else {
		connected++;
		res.send(command+` --resume /mnt/paused${connected}.conf -oJ /mnt/log${connected}.json --shards ${connected}/${clients}`).status(200).end();
		console.log(`${connected}/${clients} shards connected...`);
	}
});
app.listen(8080);
