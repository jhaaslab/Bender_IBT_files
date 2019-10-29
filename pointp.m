function points=pointp(input,TR);

%tic
pp=zeros(size(input));
pp=max(input,TR)-TR;
pp=min(pp,1);

points=zeros(size(pp));

for i=1:1:min(size(points))
    poss_sp=find(pp(i,:));
    if ~isempty(poss_sp)
          first=[1 find(diff(poss_sp)-1)+1];
          for j=1:size(first,2)
             points(i,poss_sp(first(j)))=1;
          end  
    end
end
% toc
