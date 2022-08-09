const app = require('express')();
const clients = 10;
const seed = 1277435
let connected = 0;
const command = `masscan --banners 0.0.0.0/0  -p25565 --rate=100 --source-port 61000 --excludefile exclude.conf --seed ${seed}`;
app.use((req,res) =>{
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
