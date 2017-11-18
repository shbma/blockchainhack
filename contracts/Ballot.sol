pragma solidity ^0.4.8;

/// @title Voting with delegation.
contract Ballot {
    // Голосущий
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    // Кандидат
    struct Proposal {
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    address public chairperson;

    // Переменная, хранящая состояние:
    // отображение `Voter` на всевозможные адреса.
    mapping(address => Voter) public voters;

    // Динамический массив структур Кандидатов.
    Proposal[] public proposals;

    /// Создает новое голосование
    function Ballot() {
        chairperson = msg.sender;
    }

    /// сбрасывает результаты и запускает новое голосование
    /// по выбору одного кандидита
    /// из массива имен кадидатов `proposalNames`.
    function startBallot(bytes32[] proposalNames) {
      if (msg.sender != chairperson) { throw; }

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
          throw;
        }
        voters[voter].weight = 1;
    }

    /// Передает право голоса другому адресу `to`.
    function delegate(address to) {
        // присваевает ссылку
        Voter storage sender = voters[msg.sender];
        if (sender.voted) { throw; }

        // Делегировать самому себе запрещено.
        if (to == msg.sender){ throw; }

        // Передает право голоса дальше, если `to` уже делегирован кому-то.
        // Вообще, такие петли очень опасны,
        // т.к. могут крутиться долго и сжечь весь газ в блоке.
        // В этом случае передача права голоса не произойдет,
        // но в других ситуациях все может закончится полным
        // зависанием контракта.
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // Мы обнаружили зацикливание - это недопустимо
            if (to == msg.sender){ throw; }
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

    /// Отдать голос (включая все голоса, доверенные тебе)
    /// за кандидата номер proposal по имени `proposals[proposal].name`.
    function vote(uint proposal) {
        Voter storage sender = voters[msg.sender];
        if (sender.voted) { throw; }
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
}
