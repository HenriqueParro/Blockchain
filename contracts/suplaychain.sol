// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    struct Product {
        uint id;
        string name;
        string description;
        address currentHandler;
        string location;
        uint256 timestamp;
        bool inTransit;
    }
    
    struct Handler {
        address handlerAddress;
        string handlerName;
    }
    
    mapping(uint => Product) public products;
    mapping(address => Handler) public handlers;
    uint public productCount = 0;

    event ProductCreated(uint id, string name, string description);
    event ProductTransferred(uint id, address indexed fromHandler, address indexed toHandler, string location, uint256 timestamp);

    modifier onlyRegisteredHandler() {
        require(bytes(handlers[msg.sender].handlerName).length > 0, "Handler not registered");
        _;
    }

    // Registrar um manipulador de produtos
    function registerHandler(string memory _name) public {
        handlers[msg.sender] = Handler({
            handlerAddress: msg.sender,
            handlerName: _name
        });
    }

    // Criar um novo produto para a cadeia de suprimentos
    function createProduct(string memory _name, string memory _description, string memory _location) public onlyRegisteredHandler {
        productCount++;
        products[productCount] = Product({
            id: productCount,
            name: _name,
            description: _description,
            currentHandler: msg.sender,
            location: _location,
            timestamp: block.timestamp,
            inTransit: true
        });
        emit ProductCreated(productCount, _name, _description);
    }

    // Transferir o produto para outro manipulador na cadeia de suprimentos
    function transferProduct(uint _id, address _toHandler, string memory _location) public onlyRegisteredHandler {
        require(products[_id].inTransit, "Product is not in transit");
        require(products[_id].currentHandler == msg.sender, "You are not the current handler");

        // Atualizar informações do produto
        products[_id].currentHandler = _toHandler;
        products[_id].location = _location;
        products[_id].timestamp = block.timestamp;

        emit ProductTransferred(_id, msg.sender, _toHandler, _location, block.timestamp);
    }

    // Concluir a entrega do produto na cadeia de suprimentos
    function completeDelivery(uint _id) public onlyRegisteredHandler {
        require(products[_id].inTransit, "Product delivery already completed");
        require(products[_id].currentHandler == msg.sender, "You are not the current handler");

        products[_id].inTransit = false;
    }

    // Obter detalhes de um produto
    function getProductDetails(uint _id) public view returns (string memory, string memory, address, string memory, uint256, bool) {
        Product memory product = products[_id];
        return (product.name, product.description, product.currentHandler, product.location, product.timestamp, product.inTransit);
    }

    // Obter informações de um manipulador
    function getHandlerDetails(address _handler) public view returns (string memory) {
        return handlers[_handler].handlerName;
    }
}
