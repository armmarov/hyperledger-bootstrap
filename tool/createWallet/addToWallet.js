/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 *  SPDX-License-Identifier: Apache-2.0
 */

'use strict';

// Bring key classes into scope, most importantly Fabric SDK network class
const fs = require('fs');
const { Wallets } = require('fabric-network');
const path = require('path');

const fixtures = path.resolve(__dirname, '../../');

async function main() {

    // Main try/catch block
    try {
        // A wallet stores a collection of identities
        const wallet = await Wallets.newFileSystemWallet('wallet/client1');

        // Identity to credentials to be stored in the wallet
        const credPath = path.join(fixtures, '/ca-repo/clients/client1');
        const certificate = fs.readFileSync(path.join(credPath, '/msp/signcerts/cert.pem')).toString();
        const privateKey = fs.readFileSync(path.join(credPath, '/msp/keystore/bd6c5263350cbe701435c2431d9544bfd9f15386b635fe943a62f85224fbf973_sk')).toString();

        // Load credentials into wallet
        const identityLabel = 'client1';

        const identity = {
            credentials: {
                certificate,
                privateKey
            },
            mspId: 'MyegMSP',
            type: 'X.509'
        }


        await wallet.put(identityLabel,identity);

    } catch (error) {
        console.log(`Error adding to wallet. ${error}`);
        console.log(error.stack);
    }
}

main().then(() => {
    console.log('done');
}).catch((e) => {
    console.log(e);
    console.log(e.stack);
    process.exit(-1);
});

