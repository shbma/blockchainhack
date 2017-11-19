pragma solidity ^0.4.18;

/// @title Реестр жильцов и Голосовалка дома(ов) управляемых данной УК
/// Для каждой новой УК выкладывается новый экземпляр этого контракта.
contract Votechain {
    address public initiator; //тот, кто выложил контракт

    // === Модификаторы ===

    modifier onlyInitiator() { //только тому, кто выложил контракт
        if (msg.sender != initiator) revert();
        _;
    }

    modifier onlyUkMan() { //только представителю УК
        if (msg.sender != ukMan) revert();
        _;
    }

    modifier onlyHolder() { //только жильцу
      if ( !holders[msg.sender].isActive ) revert();
      _;
    }

    modifier onlyUKorHolder() { //только жильцу или предстителю УК
      if ( (!holders[msg.sender].isActive) && (msg.sender != ukMan) ) revert();
      _;
    }
    // === РЕЕСТР ЖИЛЬЦОВ ===

    // Данные Жильца
    struct Holder{
        bool isActive; //живет в подконтрольном доме или уже нет
        uint8 square; //площадь квартиры - для учета при голосовании
        string realAddress; //факт. адрес: страна;город;улица;дом;корпус;квартира
    }

    // Голос+ жильца
    struct Vote{
      address ethAddress;
      bool vote;
    }

    // Данные УК, ведущей реестр
    struct Uk {
        bytes32 name;
        bytes32 email;
    }

    mapping(address => Holder) public holders; //реестр жильцов
    address public ukMan; //представитель УК

    //назначить заполняющейго от УК
    function setUkMan(address man) public onlyInitiator{
      ukMan = man;
    }
    //TODO: дать право заполняющему назначать новых заполняющих

    //добавить жильца
    function addHolder(address ethAddress, uint8 s, string addr) public onlyUkMan{
        holders[ethAddress] = Holder({
            isActive: true,
            square: s,
            realAddress: addr
        });
    }

    //деактивировать жильца
    function deactivateHolder(address holderAddress) public onlyUkMan {
      holders[holderAddress].isActive = false;
    }

    // === ГОЛОСОВАЛКА ===

    //вопрос, выносимый на голосование
    struct Question{
      address author; //инициатор
      string text; //формулировка
      bool isVoted; //закончено ли голосование по этому вопросу
      uint8 startTime; //когда выложен на голосование вопрос, block.timestamp
      uint8 endTime;  //когда остановлено голосование
      mapping(uint8 => Vote) votes; //текущие результаты голосования
      uint8 votesLength;
      bool isAccepted; //принят вопрос на голосовании или нет
      uint8 numberUp;
      uint8 numberDown;
    }

    Question[] public questions;

    //внести вопрос
    function addQuestion(address author, string text) public /*onlyUKorHolder*/{
      questions.push(Question({ //порядок полей НЕ МЕНЯТЬ - важно для тестов
          author: author,
          text: text,
          isVoted: false,
          startTime: uint8(block.timestamp),
          endTime: uint8(block.timestamp),
          //votes: [],
          votesLength: 0,
          isAccepted: false,
          numberUp: 0,
          numberDown: 0
        }));
    }

    //запустить голосование -- пока считаем, что это синоним публикации вопроса
    /*function startQuestion(uint position) public{
      if ( msg.sender != questions[position].author) { revert(); } //только автору

      questions[position].startTime = uint8(block.timestamp);
    } */

    //остановить голосование
    function stopQuestion(uint position) public{
      if ( msg.sender != questions[position].author) { revert(); } //только автору

      questions[position].endTime = uint8(block.timestamp);
      questions[position].isVoted = true;
      questions[position].isAccepted = calculateVotes(position);
    }

    //проголосовать.
    //@params  номер вопроса, за/против
    function vote(uint questionPosition, bool voteVal) public /*onlyHolder*/{
        var newVotesLen = questions[questionPosition].votesLength + 1;
        questions[questionPosition].votes[newVotesLen] = Vote({
            ethAddress: msg.sender,
            vote: voteVal
          });
        questions[questionPosition].votesLength++;

        //сразу пишем результаты кто за кто против
        if (voteVal){
          questions[questionPosition].numberUp = questions[questionPosition].numberUp+1;
        } else {
          questions[questionPosition].numberDown += 1;
        }
    }

    //подсчитать голоса, сказать приняли или нет
    function calculateVotes(uint questionPosition) public returns (bool result){
      uint8 votesLength = questions[questionPosition].votesLength; //кол-во голосов
      uint8 upVotesCount = 0; //число голосов ЗА

      //проходим и суммируем все голоса ЗА
      /*for(uint8 i=0; i<votesLength; i++){
        if (questions[questionPosition].votes[i].vote) {
          upVotesCount++;
        }
      }*/
      //принимаем решение исходя из соотношения ЗА и ПРОТИВ
      if (questions[questionPosition].numberUp - questions[questionPosition].numberDown > 0){
        result = true;
      } else {
        result = false;
      }

      /*if (2*upVotesCount > votesLength){
        result = true;
      } else {
        result = false;
      }*/
    }


    // === Constructor ===
    function Votechain() public{
        initiator = msg.sender;
    }

    // === Getters ===
    function getQuestionsLength() public returns (uint8){
      return uint8(questions.length);
    }

}
