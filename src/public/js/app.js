
$(function(){

    $("#specie").autocomplete({
        source: function (request, response) {
            $.getJSON(flora+"/api/v1/search/species?query="+request.term, function (data) {
                processResult(data.result, response, request.term);
            });
        }
    });

    $("#acceptedNameUsage").autocomplete({
        source: function (request, response) {
            $.getJSON(base+"/search/accepted?query="+request.term, function (data) {
                    console.log(data);
                processResult(data, response, request.term);
            });
        }
    });
            
    function processResult(data, callback, searchTerm) {
        callback($.map(data, function (value) {
            var inputAutocomplete = value.scientificNameWithoutAuthorship.toLowerCase();
            if( inputAutocomplete.indexOf( searchTerm.toLowerCase() ) != -1 
                && value.family.length >= 1) {
                return value = value.scientificNameWithoutAuthorship;
            }
        }));
    };
        
    Connect({
        context: context,
        onlogin: function(user) {
            if(!logged) {
                $.post(base+'/login','user='+JSON.stringify(user),function(){
                    location.reload();
                });
            }
        },
        onlogout: function(nothing){
            if(logged) {
                $.post(base+'/logout',nothing,function(){
                    location.reload();
                });
            }
        }
    });
                                 
    $("#login a").click(function(){ Connect.login(); });
    $("#logout a").click(function(){ Connect.logout(); });

    $(".glyphicon-remove").click(function(){
        return confirm(confirm_str);
    });
                                        
});

