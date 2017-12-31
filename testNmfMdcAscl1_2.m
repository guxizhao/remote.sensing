%% nmf_MDC_test with more than 3 endmembers
clear all
expTimes = 1;
dataSize = 900;
noiseLevel = 0.0;
bandNum = 4;
endNum = 4;
HTrue = zeros(endNum, bandNum);
HI = zeros(endNum, bandNum);
HMdc = zeros(endNum, bandNum);
WTrue = zeros(dataSize, endNum);
WI = zeros(dataSize, endNum);
WMdc = zeros(dataSize, endNum);
% for i = 1:exp_times
    % generate true W, H, V
    HTrue = abs( randn( endNum, bandNum ) );
    [V, W_true] = create4(dataSize, HTrue);
%     max_V = max(V);
%     for i = 1:bandNum
%        V(:,i) = V(:,i) / (max_V(i));
%     end
    figure;
    scatter(V(:,1), V(:,2));
    xlabel('band 1');
    ylabel('band 2');
    xlim([0,1])
    ylim([0,1])
    
    %% find initial H using n_findr
    HInitIndx = nFindr(V, endNum);
    HI = V(HInitIndx, :);
    
    alpha = 1;
    tol = 0.1;
    maxIter = 5000;
    [WI, E_I] = nmfAbundance(V, endNum, HI,...
                        alpha, tol, maxIter);
    VNmf = WI * HI;
    
    figure;
    scatter(VNmf(:,1), VNmf(:,2), 'c', 'full'); hold on
    scatter(V(:,1), V(:,2), 'r')
    scatter(HI(:, 1), HI(:, 2), 'full');
    
    % factorize V using nmf_MDC_simple method

%% mdc test
    random_ = 0;
    if random_
        % HI = abs(randn(size(HI)));
        % WI = abs(randn(size(WI)));
        [ WMdc, HMdc, HRecord, E] = ...
            hyperNmfMdcAscl1_2(...
                V, endNum, WI, HI, ...
                0.001, 4,...
                0.01, 30000 );
        WMdcRandomInit = WMdc;
        HMdcRandomInit = HMdc;
    else
        [ WMdc, HMdc, HRecord, E] = ...
            hyperNmfMdcAscl1_2(...
                V, HI, WI, ...
                0.001,... % tolObj
                20000, ... % maxIter
                0.001, ... % dDelta
                20 ... % fDelta
            );
        WMdcWellInit = WMdc;
        HMdcWellInit = HMdc;
    end   
    %% visualize rest
    VNmf = WMdc * HMdc;
    figure;
    bandIndx1 = 1;
    bandIndx2 = 2;
    scatter(V(:,bandIndx1), V(:,bandIndx2), 'c' ); hold on ; 
    scatter(HTrue(:, bandIndx1), HTrue(:, bandIndx2), 'filled', 'r');
    scatter(HI(:, bandIndx1), HI(:, bandIndx2), 'filled', 'b');
    scatter( VNmf(:,bandIndx1), VNmf(:,bandIndx2), 5, 'k' );
    scatter( HMdc(:,bandIndx1), HMdc(:,bandIndx2) , 'filled','k')
    plot(HRecord(:, 1, bandIndx1), HRecord(:, 1, bandIndx2), 'r-', 'MarkerSize', 5);
    plot(HRecord(:, 2, bandIndx1), HRecord(:, 2, bandIndx2), 'g-', 'MarkerSize', 5);
    plot(HRecord(:, 3, bandIndx1), HRecord(:, 3, bandIndx2), 'b-',  'MarkerSize', 5);