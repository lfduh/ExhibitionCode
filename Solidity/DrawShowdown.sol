pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

import "./safemath.sol";

contract DrawShowdown
{
    using SafeMath for uint16;

    struct Game
    {
        uint placedCardNum;
        uint bet;
    }

    uint256 drawFee = 100;
    uint[] cards;
    Game[] games;

    mapping( uint => address ) public cardToOwner;
    mapping( uint => address ) public gameToOwner;
    mapping( address => uint256 ) public balances;    

    event NewGame( uint index, uint bet );
    event Log( string _log );

    modifier onlyOwnerOfCard ( uint _cardId )
    {
        require( cardToOwner[_cardId] == msg.sender );
        _;
    }

    function Deposit () external
    {
        balances[msg.sender] += 10000;
    }

    function DrawCard () external
    {
        emit Log( "DrawCard" );
        require( balances[msg.sender] >= drawFee );
        balances[msg.sender] -= drawFee;
        uint randomCardNum = uint(blockhash(block.number-1)) % 13 + 1;
        
        uint id = cards.push(randomCardNum) - 1;
        cardToOwner[id] = msg.sender;
    }

    function Showdown ( uint _gameIndex, uint _cardIndex ) external onlyOwnerOfCard( _cardIndex )
    {
        Game storage game = games[_gameIndex];
        if( cards[_cardIndex] > game.placedCardNum )
        {
            balances[msg.sender] += game.bet;
            balances[gameToOwner[_gameIndex]] -= game.bet;
        }
        else if( cards[_cardIndex] < game.placedCardNum )
        {
            balances[msg.sender] -= game.bet;
            balances[gameToOwner[_gameIndex]] += game.bet;
        }
        else
        {
             balances[gameToOwner[_gameIndex]] += game.bet;
        }

        delete games[_gameIndex];
        delete cards[_cardIndex];
		delete cardToOwner[_cardIndex];
        delete gameToOwner[_gameIndex];
    }

    function GetCardsCountByOwner ( address _owner ) private view returns( uint )
    {
        uint counter = 0;
        for( uint index = 0; index < cards.length; index++ )
        {
            if( cardToOwner[index] == _owner )
            {
                counter++;
            }
        }
        
        return counter;
    }

    function GetCardsByOwner ( address _owner ) external view returns( uint[] )
    {
        uint[] memory result = new uint[]( GetCardsCountByOwner(_owner));
        uint counter = 0;
        for( uint index = 0; index < cards.length; index++ )
        {
            if( cardToOwner[index] == _owner )
            {
                result[counter] = index;
                counter++;
            }
        }

        return result;
    }
    
    function GetCards () external view returns( uint[], uint[] )
    {
        uint[] memory indexResult = new uint[]( GetCardsCountByOwner(msg.sender));
        uint[] memory cardResult = new uint[]( GetCardsCountByOwner(msg.sender));
        uint counter = 0;
        
        for( uint index = 0; index < cards.length; index++ )
        {
            if( cardToOwner[index] == msg.sender )
            {
                indexResult[counter] = index;
                cardResult[counter] = cards[index];
                counter++;
            }
        }

        return ( indexResult, cardResult );
    }

    function CreateGame ( uint _placedCardIndex, uint _bet ) external onlyOwnerOfCard( _placedCardIndex )
    {
        require( balances[msg.sender] >= _bet );
        uint index = games.push( Game( cards[_placedCardIndex], _bet )) - 1;
        balances[msg.sender] -= _bet;
        delete cards[_placedCardIndex];
        delete cardToOwner[_placedCardIndex];
        emit NewGame( index, _bet );
    }

    function GetRandomGame () external view returns( Game )
    {
        uint randGameIndex = uint(blockhash(block.number-1))% games.length;
        Game storage randGame = games[randGameIndex];
        return randGame;
    }
    
    function GetFetchGamesMaxCount () private view returns( uint )
    {
        /*
        if( games.length > 6 )
        {
            return 6;
        }
        
        return games.length;
        */
        uint counter = 0;
        for( uint index = 0; index < games.length; index ++)
        {
            if( games[index].bet > 0 )
            {
                counter++;
            }
        }
        
        return counter;
    }
    
	/*
    function GetRandomGames () external view returns( uint[], uint[] )
    {
        uint[] memory gameIndexes = new uint[]( GetFetchGamesMaxCount());
        uint[] memory gameBets = new uint[]( GetFetchGamesMaxCount());
        for( uint index = 0; index < gameIndexes.length; index ++)
        {
            uint randGameIndex = uint(blockhash(block.number-1))% games.length;
            gameIndexes[index] = randGameIndex;
            gameBets[index] = games[randGameIndex].bet;
        }
        
        return ( gameIndexes, gameBets );
    }
	*/
	    
    function GetRandomGames () external view returns ( uint[], uint[], uint[] )
    {
        uint[] memory gameIndexes = new uint[]( GetFetchGamesMaxCount());
        uint[] memory gameBets    = new uint[]( gameIndexes.length );
        uint[] memory gameCards   = new uint[]( gameIndexes.length );
        uint counter = 0;
        for( uint index = 0; index < games.length; index ++)
        {
            //uint randGameIndex = uint(blockhash(block.number-1))% games.length;
            //uint randGameIndex = rand( 0, gameIndexes.length -1 );
            if( games[index].bet == 0 ) continue;
            gameIndexes[counter] = index;
            gameBets[counter] = games[index].bet;
            gameCards[counter] = games[index].placedCardNum;
            counter++;
        }
        
        return ( gameIndexes, gameBets, gameCards );
    }

    /*
	function rand(uint min, uint max) public returns (uint256)
    {
        uint256 lastBlockNumber = block.number - 1;
        uint256 hashVal = uint256(block.blockhash(lastBlockNumber));
        
        // This turns the input data into a 100-sided die
        // by dividing by ceil(2 ^ 256 / 100).
        uint256 FACTOR = 1157920892373161954235709850086879078532699846656405640394575840079131296399;
        return uint256(uint256(hashVal) / FACTOR) + 1;
    }
    */
    
    function Ping () external pure returns( uint )
    {
        return 1;
    }
    
    function PingArray () external pure returns( uint[] )
    {
        uint[] memory result = new uint[](2);
        result[0] = 1;
        result[1] = 2;
        return result;
    }
    
    function GetAddress () external view returns ( address add )
    {
        return msg.sender;
    }
    
    function GetBalance () external view returns ( uint256 balance )
    {
        return balanceOf( msg.sender );  
    }
    
    //ERC20 Interface
    function balanceOf ( address _owner ) public constant returns ( uint256 balanceof )
	{
		return balances[_owner];
	}

    

    //ERC20 interface start
    /*
    event Transfer(address indexed _from, address indexed _to, uint _value);
	event Approval(address indexed _owner, address indexed _spender, uint _value);

    function totalSupply() constant returns (uint TotalSupply)
    {
		return _totalSupply;
	}

	function transfer( address _to, uint256 _amount ) returns ( bool success )
	{
		if( balances[msg.sender] >= _amount &&
		    _amount > 0 &&
		    balances[_to] + _amount > balances[_to] )
		{
		    balances[msg.sender] -= _amount;
			balances[_to] += _amount;
			return true;
			Transfer( msg.sender, _to, _amount );
		}
		else
		{
			return false;
		}
	}

	function transferFrom( address _from, address _to,uint256 _amount ) returns ( bool success )
	{
		if ( balances[_from] >= _amount &&
			 allowed[_from][msg.sender] >= _amount &&
			 _amount > 0 &&
			 balances[_to] + _amount > balances[_to] )
		{
			balances[_from] -= _amount;
			allowed[_from][msg.sender] -= _amount;
			balances[_to] += _amount;
			return true;
			Transfer(_from,_to,_amount);
		}
		else
		{
			return false;
		}
	}

	function approve( address _spender, uint256 _amount ) returns ( bool success )
	{
		allowed[msg.sender][_spender] = _amount;
		Approval(msg.sender, _spender, _amount);
		return true;
	}

	function allowance( address _owner, address _spender ) constant returns ( uint256 remaining )
	{
		return allowed[_owner][_spender];
	}
	*/
    //ERC20 interface end
}
