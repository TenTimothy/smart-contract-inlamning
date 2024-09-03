import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const HelloWorldModule = buildModule("HelloWorldModule", (m) => {
    const helloWorld = m.contract("HelloWorld", [], {});  

    return { helloWorld };
});

export default HelloWorldModule;