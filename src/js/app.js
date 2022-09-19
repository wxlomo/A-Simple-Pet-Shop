/*
 * app.js
 * JavaScript code for the Petshop front-end
 * Editor: Weixuan Yang
 * Date: August 19, 2022
 */

App = {
    web3Provider: null,
    contracts: {},
    petUpdatedFlag: false,
    supplyUpdatedFlag: false,

    init: async function() {
        return await App.initWeb3();
    },

    initWeb3: async function() {
        if (window.ethereum) {
            App.web3Provider = window.ethereum;
            try {
                await window.ethereum.enable();
            } catch (error) {
                console.error("User denied account access")
            }
        } else if (window.web3) {
            App.web3Provider = window.web3.currentProvider;
        } else {
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
        }
        web3 = new Web3(App.web3Provider);
        return App.initContract();
    },

    /*
     * Contract and site related functions
     */

    initContract: function() {
        /* Petshop initialization */
        $.getJSON('Petshop.json', function(data) {
            App.contracts.Petshop = TruffleContract(data);
            App.contracts.Petshop.setProvider(App.web3Provider);
            return App.renderPet();
        }).then(function(result) {
            App.listenForAddPet();
            App.listenForOwnPet();
            App.listenForVotePet();
            //App.listenForAddSupply(); // Not currently in use
            App.listenForBuySupply();
            App.hideNotification();
            return App.renderSupply();
        });
        return App.bindEvents();
    },

    bindEvents: function() {
        /* Button clicking actions */
        $(document).on('click', '.btn-adopt', App.handleAdoptReturnPet);
        $(document).on('click', '.btn-buy-pet', App.handleBuyPet);
        $(document).on('click', '.btn-vote', App.handleVotePet);
        $(document).on('click', '.btn-buy-supply', App.handleBuySupply);
        $(document).on('click', '#closeNote', App.hideNotification);
    },

    renderData: function() {
        /* Statistics updating function */
        App.contracts.Petshop.deployed().then(function(instance) {
            petshopInstance = instance;
            return petshopInstance.userTotal();
        }).then(function(userTotal) {
            $('#userTotal').text(userTotal);
            return petshopInstance.ownPetTotal()
        }).then(function(ownPetTotal) {
            $('#ownPetTotal').text(ownPetTotal);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    hideNotification: function() {
        /* Notification panel hidden function */
        $('#notification').hide();
    },

    handleDonate: function() {
        /* Donation function */
        var petshopInstance;
        var donateAmount = $("#donate").val();
        $("#donate").val("");
        web3.eth.getAccounts(function(error, accounts) {
            if (error) {
                console.log(error);
            }
            // console.log("Donating");
            // console.log(donateAmount);
            App.contracts.Petshop.deployed().then(function(instance) {
                petshopInstance = instance;
                return petshopInstance.receiveDonation({ from: accounts[0], value: donateAmount * 1e18 });
                // send designated amount of ETH to the contract
            }).catch(function(err) {
                console.log(err.message);
            });
        });
    },

    /*
     * Pet related functions
     */

    listenForAddPet: function() {
        /* Pet adding event catching function */
        App.contracts.Petshop.deployed().then(function(instance) {
            petshopInstance = instance;
            petshopInstance.addPetEvent({}, { fromBlock: 0, toBlock: 'latest' }).watch(function(error, event) {
                if (App.petUpdatedFlag == false) { // avoid to trigger the render function for multiple times
                    App.petUpdatedFlag = true;
                    return App.renderPet();
                }
            })
        })
    },

    listenForOwnPet: function() {
        /* Pet buying event catching function */
        App.contracts.Petshop.deployed().then(function(instance) {
            petshopInstance = instance;
            instance.OwnPetEvent({}, { fromBlock: 0, toBlock: 'latest' }).watch(function(error, event) {
                return App.markPetOwned();
            });
        });
    },

    listenForVotePet: function() {
        /* Pet voting event catching function */
        App.contracts.Petshop.deployed().then(function(instance) {
            petshopInstance = instance;
            instance.votePetEvent({}, { fromBlock: 0, toBlock: 'latest' }).watch(function(error, event) {
                return App.markPetVoted();
            });
        });
    },

    renderPet: function() {
        /* Pet list updating function */
        App.contracts.Petshop.deployed().then(function(instance) {
            petshopInstance = instance;
            return petshopInstance.petn();
        }).then(function(petn) {
            $('#petsRow').empty();
            for (var i = 0; i < petn; i++) {
                petshopInstance.pets(i).then((value) => { // load for pet metadata
                    $('#petTemplate').find('.panel-title').text(value[1]);
                    $('#petTemplate').find('.pet-breed').text(value[2]);
                    $('#petTemplate').find('.pet-age').text(value[3]);
                    $('#petTemplate').find('.pet-location').text(value[4]);
                    $('#petTemplate').find('.pet-price').text(value[5]);
                    $('#petTemplate').find('img').attr('src', value[6]);
                    $('#petTemplate').find('.pet-vote').text(value[7]);
                    $('#petTemplate').find('.btn-adopt').attr('data-id', value[0]);
                    $('#petTemplate').find('.btn-buy-pet').attr('data-id', value[0]);
                    $('#petTemplate').find('.btn-vote').attr('data-id', value[0]);
                    $('#petsRow').append($('#petTemplate').html());
                });
            }
            return App.markPetVoted();
        }).then(function(result) {
            return App.markPetOwned();
        }).then(function(result) {
            return App.renderData();
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    markPetOwned: function() {
        /* Pet buying, adopting, and returning related page update function */
        var petshopInstance;
        App.contracts.Petshop.deployed().then(function(instance) {
            petshopInstance = instance;
            return petshopInstance.getOwners.call();
        }).then(function(owners) {
            for (var i = 0; i < owners.length; i++) {
                if (owners[i] !== '0x0000000000000000000000000000000000000000') {
                    $('.panel-pet').eq(i).find('.btn-adopt').text('Return (Fee: 1 ETH)'); // allow to return but forbid to buy or adopt for owned pets
                    $('.panel-pet').eq(i).find('.btn-buy-pet').text('Owned').hide();
                } else {
                    $('.panel-pet').eq(i).find('.btn-adopt').text('Adopt'); // allow to adopt or buy for owned or returned pets
                    $('.panel-pet').eq(i).find('.btn-buy-pet').text('Buy').show();
                }
            }
        }).then(function(result) {
            return App.renderData();
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    markPetVoted: function() {
        /* Pet vote related page update function */
        var petshopInstance;
        App.contracts.Petshop.deployed().then(function(instance) {
            petshopInstance = instance;
            return petshopInstance.petn();
        }).then(function(petn) {
            for (var i = 0; i < petn; i++) {
                petshopInstance.pets(i).then((value) => {
                    $('.panel-pet').eq(value[0]).find('.pet-vote').text(value[7]); // update the vote count on the page
                })
            }
        }).then(function(result) {
            return petshopInstance.getVoted.call();
        }).then(function(voted) {
            if (voted) {
                $('.panel-pet').find('.btn-vote').text('Voted').hide(); // forbid to vote if already voted
            }
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    handleAddPet: function() {
        /* Pet registing function */
        App.petUpdatedFlag = false;
        var petshopInstance;
        var newname = $("#newname").val();
        var newbreed = $("#newbreed").val();
        var newage = $("#newage").val();
        var newlocation = $("#newlocation").val();
        var newprice = $("#newprice").val();
        var newimg = $("#newimg option:selected").val();
        $("#newname").val("");
        $("#newbreed").val("");
        $("#newage").val("");
        $("#newlocation").val("");
        $("#newprice").val("");
        web3.eth.getAccounts(function(error, accounts) {
            if (error) {
                console.log(error);
            }
            App.contracts.Petshop.deployed().then(function(instance) {
                petshopInstance = instance;
                // console.log(newname, newbreed, newage, newlocation, newprice, newimg);
                return petshopInstance.addPetPublic(newname, newbreed, newage, newlocation, newprice, newimg, { from: accounts[0], value: 1e18 }); // register for the pet with 1 ETH fee
            }).then(function(result) {
                $('#note').text("Your pet [" + newname + "] has been added to the shop successfully!"); // send the notification to the contract owner
                $('#notification').show();
            }).catch(function(err) {
                console.error(err);
            });
        });
    },

    handleAdoptReturnPet: function(event) {
        /* Pet adopting and returning function */
        event.preventDefault();
        var petId = parseInt($(event.target).data('id'));
        var petshopInstance;
        var returning = false;
        web3.eth.getAccounts(function(error, accounts) {
            if (error) {
                console.log(error);
            }
            //console.log("Adopting or returnning a pet");
            //console.log(petId);
            App.contracts.Petshop.deployed().then(function(instance) {
                petshopInstance = instance;
                return petshopInstance.getOwners.call();
            }).then(function(owners) {
                if (owners[petId] == 0x0000000000000000000000000000000000000000) {
                    return petshopInstance.adoptPet(petId, { from: accounts[0] }); // adopt the pet if not owned
                } else {
                    returning = true;
                    return petshopInstance.returnPet(petId, { from: accounts[0], value: 1e18 }); // return the pet if owned with 1 ETH fee
                }
            }).then(function(result) {
                return petshopInstance.getPetName.call(petId);
            }).then(function(name) {
                if (returning) {
                    $('#note').text("Your pet [" + name + "] has been returned to the shop successfully!"); // send the notification to the contract owner
                } else {
                    $('#note').text("Your pet adoption for [" + name + "] has been confirmed successfully!");
                }
                $('#notification').show();
            }).catch(function(err) {
                console.log(err.message);
            });
        });
    },

    handleBuyPet: function(event) {
        /* Pet buying function */
        event.preventDefault();
        var petId = parseInt($(event.target).data('id'));
        var petshopInstance;
        web3.eth.getAccounts(function(error, accounts) {
            if (error) {
                console.log(error);
            }
            //console.log("Buying a pet");
            App.contracts.Petshop.deployed().then(function(instance) {
                petshopInstance = instance;
                return petshopInstance.getPetPrice.call(petId); // get the price of the pet
            }).then(function(petPrice) {
                //console.log(petId, petPrice);
                return petshopInstance.buyPet(petId, { from: accounts[0], value: petPrice * 1e18 }); // buy the pet with the price
            }).then(function(result) {
                return petshopInstance.getPetName.call(petId);
            }).then(function(name) {
                $('#note').text("Your pet purchase for [" + name + "] has been confirmed successfully!"); // send the notification to the contract owner
                $('#notification').show();
            }).catch(function(err) {
                console.log(err.message);
            });
        });
    },

    handleVotePet: function(event) {
        /* Pet voting function */
        event.preventDefault();
        var petId = parseInt($(event.target).data('id'));
        var petshopInstance;
        web3.eth.getAccounts(function(error, accounts) {
            if (error) {
                console.log(error);
            }
            //console.log("Voting for a pet");
            //console.log(petId);
            App.contracts.Petshop.deployed().then(function(instance) {
                petshopInstance = instance;
                return petshopInstance.votePet(petId, { from: accounts[0] }); // vote for the pet
            }).then(function(result) {
                return petshopInstance.getPetName.call(petId);
            }).then(function(name) {
                $('#note').text("Your vote for the pet [" + name + "] has been submitted successfully!"); // send the notification to the contract owner
                $('#notification').show();
            }).catch(function(err) {
                console.log(err.message);
            });
        });
    },

    /*
     * Supply related functions
     */

    listenForAddSupply: function() {
        /* Supply adding event catching function */
        App.contracts.Petshop.deployed().then(function(instance) {
            petshopInstance = instance;
            petshopInstance.addSupplyEvent({}, { fromBlock: 0, toBlock: 'latest' }).watch(function(error, event) {
                $('#note').text("A new petsupply has been added to the shop!");
                $('#notification').show();
                if (App.supplyUpdatedFlag == false) { // avoid to trigger the render function for multiple times
                    App.supplyUpdatedFlag = true;
                    return App.renderSupply();
                }
            });
        });
    },

    listenForBuySupply: function() {
        /* Supply buying event catching function */
        App.contracts.Petshop.deployed().then(function(instance) {
            petshopInstance = instance;
            instance.buySupplyEvent({}, { fromBlock: 0, toBlock: 'latest' }).watch(function(error, event) {
                return App.markSupplyStock();
            });
        });
    },

    renderSupply: function() {
        /* Supply list updaing function */
        App.contracts.Petshop.deployed().then(function(instance) {
            petshopInstance = instance;
            return petshopInstance.supplyn();
        }).then(function(supplyn) {
            $('#suppliesRow').empty();
            for (var i = 0; i < supplyn; i++) {
                petshopInstance.supplies(i).then((value) => { // load for supply metadata
                    $('#supplyTemplate').find('.panel-title').text(value[1]);
                    $('#supplyTemplate').find('.supply-stock').text(value[2]);
                    $('#supplyTemplate').find('.supply-price').text(value[3]);
                    $('#supplyTemplate').find('img').attr('src', value[4]);
                    $('#supplyTemplate').find('.btn-buy-supply').attr('data-id', value[0]);
                    $('#suppliesRow').append($('#supplyTemplate').html());
                });
            }
            return App.markSupplyStock();
        }).then(function(result) {
            return App.renderData();
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    markSupplyStock: function() {
        /* Supply related page update function */
        var petshopInstance;
        App.contracts.Petshop.deployed().then(function(instance) {
            petshopInstance = instance;
            return petshopInstance.supplyn();
        }).then(function(supplyn) {
            for (var i = 0; i < supplyn; i++) {
                petshopInstance.supplies(i).then((value) => {
                    $('.panel-supply').eq(value[0]).find('.supply-stock').text(value[2]); // update the stock number for supplies on the page
                    if (value[2] <= 0) {
                        $('.panel-supply').eq(value[0]).find('button').text('Out of Stock').attr('disabled', true); // forbid to buy supplies if out of stock
                    }
                })
            }
        }).then(function(result) {
            return App.renderData();
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    handleBuySupply: function(event) {
        /* Supply buying function */
        event.preventDefault();
        var supplyId = parseInt($(event.target).data('id'));
        var petshopInstance;
        //console.log("Buying a pet");
        web3.eth.getAccounts(function(error, accounts) {
            if (error) {
                console.log(error);
            }
            App.contracts.Petshop.deployed().then(function(instance) {
                petshopInstance = instance;
                return petshopInstance.getSupplyPrice.call(supplyId); // get the price of the supply
            }).then(function(supplyPrice) {
                //console.log(supplyId, supplyPrice);
                App.contracts.Petshop.deployed().then(function(instance) {
                    petshopInstance = instance;
                    //console.log(supplyId);
                    return petshopInstance.buySupply(supplyId, { from: accounts[0], value: supplyPrice * 1e18 }); // buy one supply with its price
                }).then(function(result) {
                    return petshopInstance.getSupplyName.call(supplyId);
                }).then(function(name) {
                    $('#note').text("Your pet supply purchase for the item [" + name + "] has been confirmed successfully!"); // send the notification to the contract owner
                    $('#notification').show();
                }).catch(function(err) {
                    console.log(err.message);
                });
            });
        });
    },
};

$(function() {
    $(window).load(function() {
        App.init();
    });
});
