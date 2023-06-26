100*sum(data.output_table.A1_acc)/height(data.output_table.A1_acc)
100*sum(data.output_table.A2_acc)/height(data.output_table.A2_acc)
100*sum(data.output_table.Coll_acc)/height(data.output_table.Coll_acc)

c1=data.output_table.targetContrast==0.115;
c2=data.output_table.targetContrast==0.135;
c3=data.output_table.targetContrast==0.17;
c4=data.output_table.targetContrast==0.25;


%c1
100*sum(data.output_table.A1_acc(c1))/height(data.output_table.A1_acc(c1))
100*sum(data.output_table.A2_acc(c1))/height(data.output_table.A2_acc(c1))
100*sum(data.output_table.Coll_acc(c1))/height(data.output_table.Coll_acc(c1))


%c2
100*sum(data.output_table.A1_acc(c2))/height(data.output_table.A1_acc(c2))
100*sum(data.output_table.A2_acc(c2))/height(data.output_table.A2_acc(c2))
100*sum(data.output_table.Coll_acc(c2))/height(data.output_table.Coll_acc(c2))


%c3
100*sum(data.output_table.A1_acc(c3))/height(data.output_table.A1_acc(c3))
100*sum(data.output_table.A2_acc(c3))/height(data.output_table.A2_acc(c3))
100*sum(data.output_table.Coll_acc(c3))/height(data.output_table.Coll_acc(c3))


%c4
100*sum(data.output_table.A1_acc(c4))/height(data.output_table.A1_acc(c4))
100*sum(data.output_table.A2_acc(c4))/height(data.output_table.A2_acc(c4))
100*sum(data.output_table.Coll_acc(c4))/height(data.output_table.Coll_acc(c4))
