// SPDX-License-License: MIT
pragma solidity ^0.8.20;

import '../interfaces/IArtistToken.sol';
import '../interfaces/IArtistTokenFactory.sol';

import '../interfaces/ILensFluenceTippingModule.sol';
import '../interfaces/ILensHub.sol';
import '../interfaces/IPriceEngine.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/Math.sol';

contract LensFluenceTippingModule is Ownable, ILensFluenceTippingModule {
  using Math for uint256;

  address public immutable lensHub;
  IPriceEngine public priceEngine;
  IArtistTokenFactory public factory;

  // Mapeo para almacenar configuraciones de tipping por profileId
  mapping(uint256 => uint256) public minTipAmounts;

  constructor(address _lensHub, address _priceEngine, address _factory, address initialOwner) Ownable(initialOwner) {
    require(_lensHub != address(0), 'Invalid LensHub address');
    require(_priceEngine != address(0), 'Invalid PriceEngine address');
    require(_factory != address(0), 'Invalid Factory address');
    lensHub = _lensHub;
    priceEngine = IPriceEngine(_priceEngine);
    factory = IArtistTokenFactory(_factory);
  }

  modifier onlyHub() {
    require(msg.sender == lensHub, 'Only LensHub can call');
    _;
  }

  function configure(uint256 profileId, bytes calldata data) external override onlyHub returns (bytes memory) {
    // Validar que el perfil existe
    require(ILensHub(lensHub).getProfile(profileId) != address(0), 'Invalid profile');

    // Decodificar datos: monto mínimo de propina (en GHO, con precisión 1e18)
    // Si no se proporciona, usar getMintPrice como base
    uint256 minTipAmount;
    if (data.length > 0) {
      minTipAmount = abi.decode(data, (uint256));
    } else {
      minTipAmount = priceEngine.getMintPrice(profileId).mulDiv(1e18, 10); // Ejemplo: 10% del precio de mint
    }

    // Almacenar configuración
    minTipAmounts[profileId] = minTipAmount;

    emit Configured(profileId, minTipAmount);
    return data;
  }

  function execute(
    uint256 profileId,
    address transactionExecutor,
    bytes calldata data
  ) external payable override onlyHub returns (bytes memory) {
    // Validar que el perfil existe
    address profileOwner = ILensHub(lensHub).getProfile(profileId);
    require(profileOwner != address(0), 'Invalid profile');

    // Decodificar datos: monto de la propina y si se desea mintear tokens
    (uint256 tipAmount, bool mintTokens) = data.length > 0 ? abi.decode(data, (uint256, bool)) : (msg.value, false);

    // Validar monto de la propina
    require(tipAmount <= msg.value, 'Insufficient GHO sent');
    require(tipAmount >= minTipAmounts[profileId], 'Tip below minimum');

    // Obtener ArtistToken asociado (si existe)
    address artistToken = factory.profileIdToToken(profileId);

    if (mintTokens && artistToken != address(0)) {
      // Calcular cuántos tokens se pueden mintear con el tipAmount
      uint256 pricePerToken = priceEngine.getMintPrice(profileId);
      uint256 tokenAmount = tipAmount.mulDiv(1e18, pricePerToken);
      require(tokenAmount > 0, 'No tokens to mint');

      // Mintear tokens
      IArtistToken(artistToken).mintFromAction{value: tipAmount}(transactionExecutor, tokenAmount);
    } else {
      // Transferir GHO directamente al profileOwner
      payable(profileOwner).transfer(tipAmount);
    }

    // Reembolsar exceso de GHO
    if (msg.value > tipAmount) {
      payable(transactionExecutor).transfer(msg.value - tipAmount);
    }

    emit Tipped(profileId, transactionExecutor, tipAmount, mintTokens);
    return data;
  }

  function disable(uint256 profileId, bytes calldata data) external override onlyHub returns (bytes memory) {
    // Validar que el perfil existe
    require(ILensHub(lensHub).getProfile(profileId) != address(0), 'Invalid profile');

    // Eliminar configuración de tipping
    delete minTipAmounts[profileId];

    emit Disabled(profileId);
    return data;
  }

  event Configured(uint256 indexed profileId, uint256 minTipAmount);
  event Tipped(uint256 indexed profileId, address indexed executor, uint256 amount, bool mintTokens);
  event Disabled(uint256 indexed profileId);
}
