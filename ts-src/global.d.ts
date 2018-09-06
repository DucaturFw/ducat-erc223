declare var spotConfig: any;
declare var artifacts: {
  require(path: string): any;
};

declare function contract(
  title: string,
  fn: (accounts: string[]) => void
): Suite;

declare var web3: any;
