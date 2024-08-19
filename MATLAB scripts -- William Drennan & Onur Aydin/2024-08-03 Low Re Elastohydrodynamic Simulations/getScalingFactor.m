function [scalingFactor,twistAmplitude] = getScalingFactor(p,x3,x3_0,twistTarget,tol)

for i = 1:300
    scalingFactorCandidate = i;
    twistWaveform = polyval(p,scalingFactorCandidate*x3+x3_0);
    twistAmplitude = max(twistWaveform(60:130))-min(twistWaveform(60:130));
    if abs((twistTarget - twistAmplitude)) < tol
        scalingFactor = scalingFactorCandidate;
        break
    else
        scalingFactor = 0;
    end
end


end