const SolidityCoder = require("web3/lib/solidity/coder.js");

export function sig(account: string) {
  return {
    from: account
  };
}

export function sideEvents(abi: any[], tx: any) {
  const abis = abi.reduce((acc: any, a: any) => acc.concat(a), []);
  const knownEvents = abis.reduce((acc: any, a: any) => {
    if (a.type == "event") {
      var signature =
        a.name + "(" + a.inputs.map((i: any) => i.type).join(",") + ")";

      acc[web3.sha3(signature)] = {
        signature: signature,
        abi_entry: a
      };
    }
    return acc;
  }, {});

  const parsedLogs = tx.receipt.logs
    .map((rawLog: any) => {
      const event = knownEvents[rawLog.topics[0]];

      if (typeof event === "undefined") {
        return null;
      }

      const types = event.abi_entry.inputs
        .map(function(input: any) {
          return input.indexed == true ? null : input.type;
        })
        .filter(function(type: any) {
          return type != null;
        });

      const values = SolidityCoder.decodeParams(
        types,
        rawLog.data.replace("0x", "")
      );

      let index = 0;

      return {
        event: event.abi_entry.name,
        args: event.abi_entry.inputs.reduce((acc: any, input: any) => {
          acc[input.name] = input.indexed ? "indexed" : values[index++];
          return acc;
        }, {})
      };
    })
    .filter((e: any) => e !== null);

  return parsedLogs;
}
