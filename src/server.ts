import { FetchingButtonsBot } from "tg-bot-button-data-fetching";
import * as fs from 'fs';

import { execSync } from 'child_process';

const token: string = fs.readFileSync('./res/token.secret', 'utf8').split('\n')[0];
const bot = new FetchingButtonsBot(token, {polling: true});

bot.addButton('Temp', () => {
    let stdout: string = execSync("sensors | grep temp1 | awk '{print $2}'").toString();
    return stdout;
})

bot.addButton('Tmux', () => {
    let stdout: string = execSync("tmux ls").toString();
    return stdout;
})

bot.addButton('Uptime', () => {
    let stdout: string = execSync("uptime -p")
        .toString();
    return stdout;
})
