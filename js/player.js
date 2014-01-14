

SpeexPlayer = {

    loadURL : function(url, onload, onerror){
        
        var xhr = null;
        
        if(window.XMLHttpRequest){
            xhr = new XMLHttpRequest();
        }
        else if(window.ActiveXObject){
            xhr = new ActiveXObject("Microsoft.XMLHTTP");
        }
        
        xhr.responseType = "blob";
        
        xhr.onreadystatechange = function(){
            if(xhr.readyState == 4){
                if(xhr.status == 200){
                   
                    var reader = new FileReader();
                    
                    reader.onerror = onerror;
                    
                    reader.onload = function(){
                        
                        var h = reader.result.slice(0,80);
                        var d = reader.result.slice(80);
                        
                        var header = Speex.parseHeader(h);
                        
                        var sp = new Speex({
                                           quality:header.reserved1 ? header.reserved1 : 8
                                           , mode:header.mode
                                           , rate: header.rate
                                           });
                        
                        var bytes = new Uint8Array(Speex.util.str2ab(d));
                        
                        var samples = sp.decode(bytes);
                        
                        var waveData = PCMData.encode({
                                                      sampleRate: header.rate, channelCount: header.nb_channels,
                                                      bytesPerSample: 2, data: samples
                                                      }), waveDataBuf;
                        
                        waveDataBuf = Speex.util.str2ab(waveData);
                        
                        var blob = new Blob([waveDataBuf], { type: "audio/wav" });
                        
                        if(onload){
                            onload(blob);
                        }
                        
                                            };
                    
                    reader.readAsBinaryString(xhr.response);
                    
                    
                }
                else if(onerror){
                    onerror();
                }
            }
        };
        
        xhr.open("GET",url,true);
        xhr.send();
        
    },
    
    play:function(url,onload,onerror){
        this.loadURL(url,function(blob){
                     
                     var audio = document.createElement("audio");
                     
                     audio.src = URL.createObjectURL(blob);
                     audio.style.display = "none";
                     
                     document.body.appendChild(audio);
                     
                     audio.play();
                     
                     },onerror);
    }
};
