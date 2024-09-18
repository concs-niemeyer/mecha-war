// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MechaWar is ERC721 {
   
    struct Mecha {
        string name;
        string img;
        uint256 strength; 
        uint256 defense; 
        uint256 agility; 
    }

    struct BattleStruct {
        uint256 attackingMecha;
        uint256 defendingMecha;
        uint8 rounds; // Total de rodadas vencidas
        address winner;
    }

    Mecha[] public mechas;
    BattleStruct[] public battles;
    address public gameOwner;

    constructor() ERC721("MechaWar", "MWR") {
        gameOwner = msg.sender;
    }

    modifier onlyOwnerOf(uint256 _mechaID) {
        require(ownerOf(_mechaID) == msg.sender, "Apenas o dono pode batalhar com este Mecha!");
        _;
    }

    function createNewMecha(
        string memory _name,
        address _to,
        uint8 _strength,
        uint8 _defense,
        uint8 _agility,
        string memory _img
    ) public {
        require(msg.sender == gameOwner, "Apenas o dono do jogo pode criar novos Mechas!");
        require(_strength + _defense + _agility == 20, "A soma dos pontos deve ser 20");
       
        uint256 tokenId = mechas.length;
        mechas.push(Mecha(_name, _img, _strength, _defense, _agility));
        _safeMint(_to, tokenId);
    }
    function battle(uint256 _attackingMecha, uint256 _defendingMecha) public onlyOwnerOf(_attackingMecha) {
    require(_attackingMecha != _defendingMecha, "Um Mecha nao pode lutar contra si mesmo!");

    Mecha storage attacker = mechas[_attackingMecha];
    Mecha storage defender = mechas[_defendingMecha];

    uint8 attackerRounds = 0;
    uint8 defenderRounds = 0;

    // Comparar força, defesa e agilidade
    if (attacker.strength > defender.strength) {
        attackerRounds += 1;
    } else if (attacker.strength < defender.strength) {
        defenderRounds += 1;
    }

    if (attacker.defense > defender.defense) {
        attackerRounds += 1;
    } else if (attacker.defense < defender.defense) {
        defenderRounds += 1;
    }

    if (attacker.agility > defender.agility) {
        attackerRounds += 1;
    } else if (attacker.agility < defender.agility) {
        defenderRounds += 1;
    }

    // Atualizar atributos com base em quem venceu
    if (attackerRounds == 0 ){
        //Falha crítica no ataque
        attacker.strength -= 1;
         if (attacker.strength < 0) attacker.strength = 0;
        attacker.defense -= 1;
         if (attacker.defense < 0) attacker.defense = 0;
        defender.defense +=1;
    } else if (attackerRounds < defenderRounds ) {
        // Atacante perde
        defender.strength += 1;
        attacker.agility -=1;
         if (attacker.agility < 0) attacker.agility = 0;
    } else {
        // Atacante vence
        attacker.strength += 0;
    }

    // Armazenar o resultado da batalha
    address winner;
    if (attackerRounds > defenderRounds) {
        winner = ownerOf(_attackingMecha);
    } else if (defenderRounds > attackerRounds) {
        winner = ownerOf(_defendingMecha);
    } else {
        winner = address(0); // Empate
    }

    // Adiciona a batalha ao histórico
    battles.push(BattleStruct({
        attackingMecha: _attackingMecha,
        defendingMecha: _defendingMecha,
        rounds: attackerRounds > defenderRounds 
            ? attackerRounds 
            : defenderRounds,
        winner: winner
    }));
}

}
