
$(function(){
    alert('teste');
    Connect({
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

    $("#login a").click(function(){ alert('test');Connect.login(); });
    $("#logout a").click(function(){ Connect.logout(); });

    if(typeof map == 'function') {
        map();
    }

    /*
    $("#rowSelectAll").on("switch-change", function (e, data) {
        var $el = $(data.el)
              , value = data.value;
            $(".toggle-state-switch").each(function( index ) {
                  $(this).bootstrapSwitch("setState" , value);
                      });
    });
    */
    
    $("#rowSelectAll").click(function(){
        alert('test');
        }
    });
});

