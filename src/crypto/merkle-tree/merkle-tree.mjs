import { writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { StandardMerkleTree } from "@openzeppelin/merkle-tree";

const __dirname = dirname(fileURLToPath(import.meta.url));

const values = [
  ["0x1111111111111111111111111111111111111111", "5000000000000000000"],
  ["0x2222222222222222222222222222222222222222", "2500000000000000000"],
  ["0x3333333333333333333333333333333333333333", "5000000000000000000"],
  ["0x4444444444444444444444444444444444444444", "5000000000000000000"],
  ["0x5555555555555555555555555555555555555555", "7000000000000000000"],
  ["0x6666666666666666666666666666666666666666", "9000000000000000000"],
  ["0x7777777777777777777777777777777777777777", "9000000000000000000"],
  ["0x8888888888888888888888888888888888888888", "9000000000000000000"],
];

const tree = StandardMerkleTree.of(values, ["address", "uint256"]);

console.log("Merkle Root:", tree.root);

writeFileSync(
  join(__dirname, "merkle-tree.json"),
  JSON.stringify(tree.dump(), false, 2)
);

// calculate proofs for a leafs
for (const [i, v] of tree.entries()) {
  const proof = tree.getProof(i);
  console.log(`Proof for leaf ${i} with value ${v}:`, proof);
}
