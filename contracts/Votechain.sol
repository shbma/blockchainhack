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

    modifier onlyHolder(address addr){ //только жильцу
      if ( holders[msg.sender].square != 0) revert();
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
      bool isVoted; //закончено ли голосование по этому вопросу
      uint8 startTime; //когда выложен на голосование вопрос, block.timestamp
      uint8 endTime;  //когда остановлено голосование
      mapping(uint8 => Vote) votes; //текущие результаты голосования
      bool isAccepted; //принят вопрос на голосовании или нет
    }

    Question[] public questions;

    //внести вопрос
    function addQuestion(address author) public{
      questions.push(Question({
          author: author,
          isVoted: false,
          startTime: uint8(block.timestamp),
          endTime: uint8(block.timestamp),
          //votes: [],
          isAccepted: false
        }));
    }

    //запустить голосование
    function startQuestion(uint position) public{
      questions[position].startTime = uint8(block.timestamp);
    }

    //остановить голосование
    function stopQuestion(uint position) public{
      questions[position].endTime = uint8(block.timestamp);
      questions[position].isVoted = true;
      questions[position].isAccepted = calculateVotes(position);
    }

    //проголосовать.
    //@params  номер вопроса, за/против
    function vote(uint questionPosition, bool voteVal) public onlyHolder{
        questions[questionPosition].votes.push(Vote({
            ethAddress: msg.sender,
            vote: voteVal
          }));
    }

    //подсчитать голоса
    function calculateVotes(uint questionPosition) public returns (bool result){
      //...
      return result = true;
    }


    // === Constructor ===
    function Votechain() public{
        initiator = msg.sender;
    }

/*
    /// Отдать голос (включая все голоса, доверенные тебе)
    /// за кандидата номер proposal по имени `proposals[proposal].name`.
    function vote(uint proposal) {
        Voter storage sender = voters[msg.sender];
        if (sender.voted) { revert(); }
        sender.voted = true;
        sender.vote = proposal;

        // Если номер `proposal` указывает за пределы массива,
        // автоматически вылетаем и откатываем все изменения.
        proposals[proposal].voteCount += sender.weight;
    }

    /// @dev Высчитывает победителя, учитывая всех проголосовавших
    /// к данному моменту.
    function winningProposal() constant
            returns (uint winningProposal)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal = p;
            }
        }
    }

    // Вызывает функцию winningProposal(), чтобы получить позицию
    // выигравшего кандидата и затем возвращает имя победителя
    function winnerName() constant
            returns (bytes32 winnerName)
    {
        winnerName = proposals[winningProposal()].name;
    }

//----------------------------

    /// сбрасывает результаты и запускает новое голосование
    /// по выбору одного кандидита
    /// из массива имен кадидатов `proposalNames`.
    function startBallot(bytes32[] proposalNames) {
      if (msg.sender != chairperson) { revert(); }

      voters[chairperson].weight = 1;

      // Для каждого имени во входном массиве
      // создает новый объект-кандидат и дописывает его
      // в конец массива
      for (uint i = 0; i < proposalNames.length; i++) {
          // `Proposal({...})` создает временный объект Proposal
          //  and `proposals.push(...)`
          //  добавляет его в конец `proposals`.
          proposals.push(Proposal({
              name: proposalNames[i],
              voteCount: 0
          }));
      }

    }

    // Дает право адресу `voter` голосовать на этих выборах.
    // Может быть вызвана только `председателем`.
    function giveRightToVote(address voter) {
        // Если аргумент `require` ложь, то она остановит выполнение
        // и вернет все к исходному состоянияю, а также
        // все Эфиры по прежним адресам.
        // Но будте осторожны - в этом случае сгорит весь имеющийся газ.
        if ( !((msg.sender == chairperson) && !voters[voter].voted && (voters[voter].weight == 0)) ){
          revert();
        }
        voters[voter].weight = 1;
    }

    /// Передает право голоса другому адресу `to`.
    function delegate(address to) {
        // присваевает ссылку
        Voter storage sender = voters[msg.sender];
        if (sender.voted) { revert(); }

        // Делегировать самому себе запрещено.
        if (to == msg.sender){ revert(); }

        // Передает право голоса дальше, если `to` уже делегирован кому-то.
        // Вообще, такие петли очень опасны,
        // т.к. могут крутиться долго и сжечь весь газ в блоке.
        // В этом случае передача права голоса не произойдет,
        // но в других ситуациях все может закончится полным
        // зависанием контракта.
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // Мы обнаружили зацикливание - это недопустимо
            if (to == msg.sender){ revert(); }
        }

        // Поскольку `sender` является ссылкой, конструкция ниже
        // изменяет `voters[msg.sender].voted`
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate = voters[to];
        if (delegate.voted) {
            // Если представитель уже проголосовал,
            // вручную добавим его голос к кол-ву голосов за его кандидита
            proposals[delegate.vote].voteCount += sender.weight;
        } else {
            // Если представитель еще не проголосовал,
            // увеличим на единичку вес его голоса.
            delegate.weight += sender.weight;
        }
    }
*/

}
