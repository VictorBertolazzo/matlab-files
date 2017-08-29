% % Simple Routine to extract N lines for bezier path required by Chrono.
% % manageData has to be called, hence DeCasteObj function call in order to
% get access to "main" obj.

points = main.X;
tol = .01
knots = zeros(2,size(CP,2)+1); 
k_last = 1;
for j=1:size(CP,2)-1
%     keyboard
    xt = CP(1,j)+(CP(1,j+1)-CP(1,j))/2;
    yt = CP(2,j)+(CP(2,j+1)-CP(2,j))/2;
    prev_diff = 20.;
    for k=k_last:size(points,2)
        diff = norm([xt-points(1,k),yt-points(2,k)]);
        if(diff < prev_diff)
          % Go through next k
         prev_diff = diff;
        else
            k_last = k;
            knots(1:2,j+1)= points(1:2,k_last);
            break;
        end
        
    end % k-for
    
end % j-for
knots(1:2,1) = points(1:2,1);
knots(1:2,end) = points(1:2,end);
% % Plotting Extracted Curve
figure,plot(knots(1,:),knots(2,:),'b',CP(1,:),CP(2,:),'ro')
%%
% % Send to a Data File
% % % Default Value for z-coordinate is 0.1-->IT MUST BE CONTROLLED
ChKnots = horzcat(knots',.1*ones(size(knots,2),1));
ChCPprec = horzcat((horzcat(CP(:,1),CP))',.1*ones(size(knots,2),1));
ChCPsucc = horzcat((horzcat(CP,CP(:,end)))',.1*ones(size(knots,2),1));

Matrix = horzcat(ChKnots,ChCPprec,ChCPsucc);
dlmwrite('WL_Path_First_Segment.dat',Matrix,'delimiter','\t','precision',5);