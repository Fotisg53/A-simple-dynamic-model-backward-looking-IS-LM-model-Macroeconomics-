%  2nd Assignment

%  Exercise 1: Steady State
%  Exercise 2: Dynamic Transition
%  Exercise 3: Permanent Policy Shocks
%  Exercise 4: Transitory Policy Shocks


clear; 
clc;



%  Exercise 1: Steady State

C_bar = 0.6;
I_bar = 0.2;
c     = 0.5;
alpha = 0.1;
b     = 0.1;
G     = 1.7;
T     = 1.7;
i     = 0.04;

ss = solve_steady_state(C_bar, I_bar, c, alpha, b, G, T, i);

fprintf('=== EXERCISE 1: Steady State ===\n');
fprintf('  Y* = %.6f\n', ss.Y);
fprintf('  C* = %.6f\n', ss.C);
fprintf('  I* = %.6f\n', ss.I);
fprintf('  Multiplier = %.4f\n\n', ss.multiplier);






% Exercise 2: Dynamic Transition

T_sim       = 40;
Y_init_frac = 0.9;

base_params.C_bar = C_bar;
base_params.I_bar = I_bar;
base_params.c     = c;
base_params.alpha = alpha;
base_params.b     = b;
base_params.G     = G;
base_params.T     = T;
base_params.i     = i;

% Task 1 – Baseline (c = 0.5)

sim_base = simulate_transition(base_params, T_sim, Y_init_frac);
plot_single_transition(sim_base, 'Baseline  (c = 0.5)');

% Task 3 – Repeat for c = 0.4 and c = 0.7
for c_val = [0.4, 0.7]
    p   = base_params;
    p.c = c_val;
    sim = simulate_transition(p, T_sim, Y_init_frac);
    plot_single_transition(sim, sprintf('c = %.1f', c_val));
end

% Task 4 – Combined comparison c = [0.4, 0.5, 0.7]
c_values = [0.4, 0.5, 0.7];
clr_ex2  = [0.20 0.53 0.74;
            0.87 0.43 0.14;
            0.17 0.63 0.30];
lsty = {'-', '--', ':'};

sims_ex2 = cell(3,1);
for k = 1:3
    p   = base_params;
    p.c = c_values(k);
    sims_ex2{k} = simulate_transition(p, T_sim, Y_init_frac);
end

vars_ex2  = {'Y','C','I'};
names_ex2 = {'Output  Y_t','Consumption  C_t','Investment  I_t'};
ss_ex2    = {'Y_ss','C_ss','I_ss'};

fig_ex2 = figure('Name','Ex2 Task4 — MPC Comparison','NumberTitle','off',...
                 'Position',[80 80 1200 420]);




% Task 2: Plot with the dynamic path of the endogenous variables of the model


for v = 1:3
    ax = subplot(1,3,v);
    hold(ax,'on');
    for k = 1:3
        s = sims_ex2{k};
        plot(ax, s.t, s.(vars_ex2{v}), lsty{k}, ...
             'Color', clr_ex2(k,:), 'LineWidth', 1.8, ...
             'DisplayName', sprintf('c = %.1f', c_values(k)));
        yline(ax, s.(ss_ex2{v}), lsty{k}, ...
              'Color', [clr_ex2(k,:), 0.35], 'LineWidth', 0.8, ...
              'HandleVisibility','off');
    end
    xlabel(ax,'Period','FontSize',10);
    ylabel(ax,names_ex2{v},'FontSize',10);
    title(ax,names_ex2{v},'FontSize',11,'FontWeight','bold');
    grid(ax,'on'); box(ax,'on');
    xlim(ax,[sims_ex2{1}.t(1)-0.5, sims_ex2{1}.t(end)]);
    if v == 1, legend(ax,'Location','southeast','FontSize',9,'Box','off'); end
end
sgtitle(fig_ex2, ...
    sprintf('Ex2: Dynamic Transition — Y_{-1}=%.0f%% of Y*, c \\in {0.4, 0.5, 0.7}', ...
            Y_init_frac*100), 'FontSize',12,'FontWeight','bold');








% Exercise 3: Permanent Policy Shocks

gamma = 0.7;

p1 = base_params; p1.G = 1.5 * base_params.G;
p2 = base_params; p2.T = 1.3 * base_params.T;
p3 = base_params; p3.i = base_params.i + 0.01;

r1 = compute_policy_shock(base_params, p1, T_sim, gamma);
r2 = compute_policy_shock(base_params, p2, T_sim, gamma);
r3 = compute_policy_shock(base_params, p3, T_sim, gamma);

shocks       = {r1, r2, r3};
shock_labels = {'Shock 1: G \uparrow 50%  (G: 1.70 \rightarrow 2.55)', ...
                'Shock 2: T \uparrow 30%  (T: 1.70 \rightarrow 2.21)', ...
                'Shock 3: i \uparrow 100bps  (i: 0.04 \rightarrow 0.05)'};
shock_short  = {'G up 50%','T up 30%','i up 100bps'};
clr_sh       = [0.86 0.37 0.22; 0.25 0.65 0.40; 0.62 0.35 0.70];

fprintf('=== EXERCISE 3: New Steady States ===\n');
fprintf('%-20s %8s %8s %8s %8s\n','','Y*','C*','I*','L*');
fprintf('%s\n',repmat('-',1,56));
fprintf('%-20s %8.4f %8.4f %8.4f %8.4f\n','Baseline', ...
    r1.ss_old.Y, r1.ss_old.C, r1.ss_old.I, r1.ss_old.L);
fprintf('%s\n',repmat('-',1,56));
for s = 1:3
    r = shocks{s};
    fprintf('%-20s %8.4f %8.4f %8.4f %8.4f\n', shock_short{s}, ...
        r.ss_new.Y, r.ss_new.C, r.ss_new.I, r.ss_new.L);
    fprintf('  Delta SS       %8.4f %8.4f %8.4f %8.4f\n', ...
        r.delta_ss.Y, r.delta_ss.C, r.delta_ss.I, r.delta_ss.L);
    fprintf('%s\n',repmat('-',1,56));
end


% Bar chart: old vs new SS

fig3_1 = figure('Name','Ex3 — Old vs New Steady States','NumberTitle','off',...
                'Position',[60 60 1200 430]);
bar_flds  = {'Y','C','I','L'};
bar_names = {'Output Y*','Consumption C*','Investment I*','Employment L*'};
for v = 1:4
    ax = subplot(1,4,v);
    old_val  = r1.ss_old.(bar_flds{v});
    new_vals = [shocks{1}.ss_new.(bar_flds{v});
                shocks{2}.ss_new.(bar_flds{v});
                shocks{3}.ss_new.(bar_flds{v})];
    all_vals = [old_val; new_vals];
    bh = bar(ax, all_vals, 0.65);
    bh.FaceColor = 'flat';
    bh.CData(1,:) = [0.35 0.55 0.77];
    for k = 1:3, bh.CData(k+1,:) = clr_sh(k,:); end
    for k = 1:4
        text(ax,k,all_vals(k)*1.01,sprintf('%.3f',all_vals(k)),...
             'HorizontalAlignment','center','FontSize',7.5,'FontWeight','bold');
    end
    yline(ax, old_val,'--','Color',[0.35 0.55 0.77]*0.8,'LineWidth',1.2);
    set(ax,'XTickLabel',{'Baseline','Shock1','Shock2','Shock3'},...
           'XTickLabelRotation',30,'FontSize',8);
    title(ax,bar_names{v},'FontSize',10,'FontWeight','bold');
    grid(ax,'on'); box(ax,'on');
end
sgtitle(fig3_1,'Ex3: Old vs New Steady States','FontSize',13,'FontWeight','bold');


% One figure per shock

dyn_flds  = {'Y','C','I','L'};
dyn_names = {'Output Y_t','Consumption C_t','Investment I_t','Employment L_t'};
for s = 1:3
    r   = shocks{s};
    fig = figure('Name',sprintf('Ex3 Shock%d Transition',s),...
                 'NumberTitle','off','Position',[80+s*25 90 1200 380]);
    ss_old_v = [r.ss_old.Y, r.ss_old.C, r.ss_old.I, r.ss_old.L];
    ss_new_v = [r.ss_new.Y, r.ss_new.C, r.ss_new.I, r.ss_new.L];
    for v = 1:4
        ax  = subplot(1,4,v);
        y_v = r.(dyn_flds{v});
        t   = r.t;
        fill(ax,[t;flipud(t)],[y_v;ss_new_v(v)*ones(size(y_v))],...
             clr_sh(s,:),'FaceAlpha',0.10,'EdgeColor','none');
        hold(ax,'on');
        yline(ax,ss_old_v(v),':','Color',[0.4 0.4 0.4],'LineWidth',1.6,...
              'DisplayName',sprintf('Old SS=%.4f',ss_old_v(v)));
        yline(ax,ss_new_v(v),'--','Color',clr_sh(s,:)*0.85,'LineWidth',1.8,...
              'DisplayName',sprintf('New SS=%.4f',ss_new_v(v)));
        plot(ax,t,y_v,'-o','Color',clr_sh(s,:),'LineWidth',1.8,...
             'MarkerFaceColor',clr_sh(s,:),'MarkerSize',3.5,...
             'DisplayName','Transition path');
        plot(ax,t(1),y_v(1),'ks','MarkerFaceColor',[0.9 0.75 0.1],...
             'MarkerSize',7,'DisplayName',sprintf('t_{0}=%.4f',y_v(1)));
        xlabel(ax,'Period','FontSize',9); ylabel(ax,dyn_names{v},'FontSize',9);
        title(ax,dyn_names{v},'FontSize',10,'FontWeight','bold');
        if v==1, legend(ax,'Location','best','FontSize',7.5,'Box','off'); end
        grid(ax,'on'); box(ax,'on'); set(ax,'FontSize',8);
        xlim(ax,[t(1)-0.3, t(end)]);
    end
    sgtitle(fig,shock_labels{s},'FontSize',12,'FontWeight','bold');
end



% Overlay all shocks

fig3_ov = figure('Name','Ex3 — All Shocks Overlay','NumberTitle','off',...
                 'Position',[100 100 1200 400]);
for v = 1:4
    ax = subplot(1,4,v);
    hold(ax,'on');
    yline(ax,r1.ss_old.(dyn_flds{v}),'-','Color',[0.65 0.65 0.65],...
          'LineWidth',1.0,'DisplayName','Old SS');
    for s = 1:3
        r   = shocks{s};
        y_v = r.(dyn_flds{v});
        plot(ax,r.t,y_v,lsty{s},'Color',clr_sh(s,:),'LineWidth',1.8,...
             'DisplayName',shock_short{s});
        yline(ax,r.ss_new.(dyn_flds{v}),lsty{s},...
              'Color',[clr_sh(s,:),0.4],'LineWidth',0.8,'HandleVisibility','off');
    end
    xlabel(ax,'Period','FontSize',9); ylabel(ax,dyn_names{v},'FontSize',9);
    title(ax,dyn_names{v},'FontSize',10,'FontWeight','bold');
    grid(ax,'on'); box(ax,'on'); set(ax,'FontSize',8);
    xlim(ax,[r1.t(1)-0.3, r1.t(end)]);
    if v==1, legend(ax,'Location','best','FontSize',7.5,'Box','off'); end
end
sgtitle(fig3_ov,'Ex3: All Three Permanent Policy Shocks — Overlay',...
        'FontSize',12,'FontWeight','bold');







% Exercise 4 — Transitory Policy Shocks



gamma  = 0.7;
T_sim4 = 40;

%% ── 4.1: G shock, DEBT-FINANCED  (T unchanged, rho_G = 0.5) 

%   G_1 = 1.1*G,  G_t = G_ss + rho_G*(G_{t-1}-G_ss) for t>=2

rho_G = 0.5;
s41   = simulate_transitory(base_params, 'G', 0.10, rho_G, T_sim4, gamma, false);



% 4.2: G shock, BALANCED BUDGET  (T_t = G_t at all t)

rho_G = 0.5;
s42 = simulate_transitory(base_params, 'G', 0.10, rho_G, T_sim4, gamma, true);

% Figure 4.1+4.2: 2x3 layout (G, T | Y, C | I, L) 
clr41 = [0.20 0.50 0.80];
clr42 = [0.85 0.33 0.10];

fig42 = figure('Name','Ex4.1-4.2 G Shock: Debt vs Balanced Budget',...
               'NumberTitle','off','Position',[70 70 1300 580]);

endo_flds  = {'Y','C','I','L'};
endo_names = {'Output Y_t','Consumption C_t','Investment I_t','Employment L_t'};
ss_refs    = {s41.Y_ss, s41.C_ss, s41.I_ss, s41.L_ss};



% (1,1) — Government Spending G_t  [same for both scenarios]

% Include t=0 (G_ss) so the jump at t=1 is visible
subplot(2,3,1);
plot(s41.t, s41.G_path, 'b-o', 'LineWidth', 1.8, 'MarkerSize', 3, ...
     'MarkerFaceColor', 'b'); hold on;
yline(base_params.G, 'k--', 'LineWidth', 1.2);
ylim([base_params.G * 0.97, max(s41.G_path) * 1.03]);
xlabel('t'); ylabel('G_t');
title('Policy: Government Spending G_t','FontSize',10,'FontWeight','bold');
legend({'G_t (both scenarios)','Steady state G^*'}, 'Location','northeast','Box','off');
grid on; box on;



% (1,2) — Taxes T_t  [differ between scenarios]

subplot(2,3,2);
plot(s41.t, s41.T_path, '-',  'Color', clr41, 'LineWidth', 1.8,...
     'DisplayName','Debt-financed  (T = T^*)'); hold on;
plot(s42.t, s42.T_path, '--', 'Color', clr42, 'LineWidth', 1.8,...
     'DisplayName','Balanced budget  (T_t = G_t)');
yline(base_params.T, 'k:', 'LineWidth', 1, 'HandleVisibility','off');
xlabel('t'); ylabel('T_t');
title('Policy: Taxes T_t','FontSize',10,'FontWeight','bold');
legend('Location','northeast','FontSize',8,'Box','off');
grid on; box on;



% (1,3) — Output Y_t

subplot(2,3,3);
plot(s41.t, s41.Y, '-',  'Color', clr41, 'LineWidth', 1.8,...
     'DisplayName','Debt-financed'); hold on;
plot(s42.t, s42.Y, '--', 'Color', clr42, 'LineWidth', 1.8,...
     'DisplayName','Balanced budget');
yline(s41.Y_ss, 'k:', 'LineWidth', 1, 'HandleVisibility','off');
xlabel('t'); ylabel('Y_t');
title('Output Y_t','FontSize',10,'FontWeight','bold');
legend('Location','southeast','FontSize',8,'Box','off');
grid on; box on;



% (2,1) — Consumption C_t

subplot(2,3,4);
plot(s41.t, s41.C, '-',  'Color', clr41, 'LineWidth', 1.8); hold on;
plot(s42.t, s42.C, '--', 'Color', clr42, 'LineWidth', 1.8);
yline(s41.C_ss, 'k:', 'LineWidth', 1);
xlabel('t'); ylabel('C_t');
title('Consumption C_t','FontSize',10,'FontWeight','bold');
grid on; box on;



% (2,2) — Investment I_t

subplot(2,3,5);
plot(s41.t, s41.I, '-',  'Color', clr41, 'LineWidth', 1.8); hold on;
plot(s42.t, s42.I, '--', 'Color', clr42, 'LineWidth', 1.8);
yline(s41.I_ss, 'k:', 'LineWidth', 1);
xlabel('t'); ylabel('I_t');
title('Investment I_t','FontSize',10,'FontWeight','bold');
grid on; box on;



% (2,3) — Employment L_t

subplot(2,3,6);
plot(s41.t, s41.L, '-',  'Color', clr41, 'LineWidth', 1.8); hold on;
plot(s42.t, s42.L, '--', 'Color', clr42, 'LineWidth', 1.8);
yline(s41.L_ss, 'k:', 'LineWidth', 1);
xlabel('t'); ylabel('L_t');
title('Employment L_t','FontSize',10,'FontWeight','bold');
grid on; box on;

sgtitle(fig42, ...
    'Exercise 4.1–4.2: Transitory G Shock — Debt-Financed vs Balanced Budget  (\rho_G = 0.5)',...
    'FontSize',12,'FontWeight','bold');


% Explanation in command window

fprintf('=== EXERCISE 4.2: Debt vs Balanced Budget ===\n');
fprintf('  Peak Y deviation — Debt:    %.4f\n', max(s41.Y) - s41.Y_ss);
fprintf('  Peak Y deviation — Bal.Bud: %.4f\n', max(s42.Y) - s42.Y_ss);
fprintf('  Interpretation: Under debt financing, the full multiplier operates.\n');
fprintf('  Under balanced budget, the tax increase partially offsets G, dampening\n');
fprintf('  the expansion. The lag structure means T effect appears one period later.\n\n');



% Sensitivity 4.1: vary rho_G 

rho_vals  = [0.1, 0.3, 0.5, 0.7, 0.9];
clr_rho   = cool(length(rho_vals));

fig4s1 = figure('Name','Ex4.1 Sensitivity rho_G','NumberTitle','off',...
                'Position',[70 70 1100 420]);
endo_sens = {'Y','C','I','L'};
for v = 1:4
    ax = subplot(1,4,v); hold(ax,'on'); grid(ax,'on'); box(ax,'on');
    xlabel(ax,'t'); ylabel(ax,['\Delta' endo_sens{v} '_t']);
    title(ax,[endo_names{v} '  deviation'],'FontSize',9);
    yline(ax,0,'k:','LineWidth',1);
    for k = 1:length(rho_vals)
        sk = simulate_transitory(base_params,'G',0.10,rho_vals(k),T_sim4,gamma,false);
        ss_ref = sk.([endo_sens{v} '_ss']);
        plot(ax, sk.t, sk.(endo_sens{v}) - ss_ref, '-', ...
             'Color',clr_rho(k,:),'LineWidth',1.6,...
             'DisplayName',sprintf('\\rho_G=%.1f',rho_vals(k)));
    end
    if v==1, legend(ax,'Location','northeast','FontSize',8,'Box','off'); end
end
sgtitle(fig4s1,'Ex4.1: Sensitivity to \rho_G — Debt-Financed G Shock',...
        'FontSize',12,'FontWeight','bold');



%% 4.3: T shock  (rho_T = 0.5) 

%   T_1 = 1.1*T,  T_t = T_ss + rho_T*(T_{t-1}-T_ss) for t>=2
rho_T = 0.5;
s43   = simulate_transitory(base_params, 'T', 0.10, rho_T, T_sim4, gamma, false);

clr43 = [0.47 0.67 0.19];       

fig43 = figure('Name','Ex4.3 Transitory T Shock','NumberTitle','off',...
               'Position',[70 70 1350 500]);

subplot(2,4,1);
plot(s43.t, s43.T_path,'-','Color',clr43,'LineWidth',1.8); hold on;
yline(base_params.T,'k:','LineWidth',1); xlabel('t'); ylabel('T_t');
title('Taxes T_t'); grid on;
legend({'T_t (shock)','T^*'},'Location','northeast','Box','off');

subplot(2,4,2); axis off;  % placeholder

for v = 1:4
    ax = subplot(2,4,4+v); hold(ax,'on');
    plot(ax, s43.t, s43.(endo_flds{v}),'-','Color',clr43,'LineWidth',1.8);
    yline(ax, s43.([endo_flds{v} '_ss']),'k:','LineWidth',1);
    xlabel(ax,'t'); ylabel(ax,endo_flds{v});
    title(ax,endo_names{v},'FontSize',10,'FontWeight','bold');
    grid(ax,'on'); box(ax,'on');
end
sgtitle(fig43,'Exercise 4.3: Transitory 10% Tax Increase (\rho_T=0.5)',...
        'FontSize',12,'FontWeight','bold');



% Brief economic interpretation 

fprintf('=== EXERCISE 4.3: Transitory T shock ===\n');
fprintf('  T increases at t=1 (10%%). Because T_{t-1} enters C_t with a lag,\n');
fprintf('  the first effect on Y appears at t=2 (one-period delay).\n');
fprintf('  Higher taxes reduce disposable income -> lower C -> lower Y and L.\n');
fprintf('  The shock decays at rate rho_T=0.5, so economy returns to SS.\n\n');



% Sensitivity 4.3: vary rho_T 

fig4s3 = figure('Name','Ex4.3 Sensitivity rho_T','NumberTitle','off',...
                'Position',[70 70 1100 420]);
for v = 1:4
    ax = subplot(1,4,v); hold(ax,'on'); grid(ax,'on'); box(ax,'on');
    xlabel(ax,'t'); ylabel(ax,['\Delta' endo_sens{v} '_t']);
    title(ax,[endo_names{v} '  deviation'],'FontSize',9);
    yline(ax,0,'k:','LineWidth',1);
    for k = 1:length(rho_vals)
        sk = simulate_transitory(base_params,'T',0.10,rho_vals(k),T_sim4,gamma,false);
        ss_ref = sk.([endo_sens{v} '_ss']);
        plot(ax, sk.t, sk.(endo_sens{v}) - ss_ref, '-', ...
             'Color',clr_rho(k,:),'LineWidth',1.6,...
             'DisplayName',sprintf('\\rho_T=%.1f',rho_vals(k)));
    end
    if v==1, legend(ax,'Location','southeast','FontSize',8,'Box','off'); end
end
sgtitle(fig4s3,'Ex4.3: Sensitivity to \rho_T — Transitory Tax Shock',...
        'FontSize',12,'FontWeight','bold');

%% 4.4: Monetary shock  +75bps, rho_i = 0.5 
%   i_1 = i_ss + 0.0075,  i_t = i_ss + rho_i*(i_{t-1}-i_ss)  for t>=2
rho_i = 0.5;
s44   = simulate_transitory(base_params, 'i', 0.0075, rho_i, T_sim4, gamma, false);

clr44 = [0.63 0.35 0.71];

fig44 = figure('Name','Ex4.4 Monetary Shock','NumberTitle','off',...
               'Position',[70 70 1350 500]);

subplot(2,4,1);
plot(s44.t, s44.i_path*100,'-','Color',clr44,'LineWidth',1.8); hold on;
yline(base_params.i*100,'k:','LineWidth',1); xlabel('t'); ylabel('i_t (%)');
title('Interest Rate i_t'); grid on;
legend({'i_t (shock)','i^*'},'Location','northeast','Box','off');

subplot(2,4,2); axis off;

for v = 1:4
    ax = subplot(2,4,4+v); hold(ax,'on');
    plot(ax, s44.t, s44.(endo_flds{v}),'-','Color',clr44,'LineWidth',1.8);
    yline(ax, s44.([endo_flds{v} '_ss']),'k:','LineWidth',1);
    xlabel(ax,'t'); ylabel(ax,endo_flds{v});
    title(ax,endo_names{v},'FontSize',10,'FontWeight','bold');
    grid(ax,'on'); box(ax,'on');
end
sgtitle(fig44,'Exercise 4.4: Transitory Monetary Tightening (+75bps, \rho_i=0.5)',...
        'FontSize',12,'FontWeight','bold');

fprintf('=== EXERCISE 4.4: Monetary shock ===\n');
fprintf('  Interest rate rises at t=1 by 75bps. Because i_{t-1} enters I_t\n');
fprintf('  with a lag, the first effect on I and Y appears at t=2.\n');
fprintf('  Higher i -> lower I -> lower Y and L. Shock decays at rate rho_i=0.5.\n\n');

% Sensitivity 4.4: vary rho_i 
fig4s4 = figure('Name','Ex4.4 Sensitivity rho_i','NumberTitle','off',...
                'Position',[70 70 1100 420]);
for v = 1:4
    ax = subplot(1,4,v); hold(ax,'on'); grid(ax,'on'); box(ax,'on');
    xlabel(ax,'t'); ylabel(ax,['\Delta' endo_sens{v} '_t']);
    title(ax,[endo_names{v} '  deviation'],'FontSize',9);
    yline(ax,0,'k:','LineWidth',1);
    for k = 1:length(rho_vals)
        sk = simulate_transitory(base_params,'i',0.0075,rho_vals(k),T_sim4,gamma,false);
        ss_ref = sk.([endo_sens{v} '_ss']);
        plot(ax, sk.t, sk.(endo_sens{v}) - ss_ref, '-', ...
             'Color',clr_rho(k,:),'LineWidth',1.6,...
             'DisplayName',sprintf('\\rho_i=%.1f',rho_vals(k)));
    end
    if v==1, legend(ax,'Location','southeast','FontSize',8,'Box','off'); end
end
sgtitle(fig4s4,'Ex4.4: Sensitivity to \rho_i — Transitory Monetary Shock',...
        'FontSize',12,'FontWeight','bold');





%%  LOCAL FUNCTIONS

function ss = solve_steady_state(C_bar, I_bar, c, alpha, b, G, T, i)
    if abs(1 - c - alpha) < 1e-12
        error('solve_steady_state:singular','1-c-alpha=0: no steady state.');
    end
    if c + alpha >= 1
        warning('solve_steady_state:unstable','c+alpha>=1: unstable model.');
    end
    multiplier = 1 / (1 - c - alpha);
    Y_ss = (C_bar + I_bar + G - c*T - b*i) * multiplier;
    ss.Y          = Y_ss;
    ss.C          = C_bar + c*(Y_ss - T);
    ss.I          = I_bar + alpha*Y_ss - b*i;
    ss.G          = G;
    ss.T          = T;
    ss.i          = i;
    ss.multiplier = multiplier;
end

function sim = simulate_transition(params, T_sim, Y_init_frac)
% Dynamic transition from Y_{-1} = Y_init_frac * Y*  to  Y*

    if nargin < 2 || isempty(T_sim),       T_sim       = 40;  end
    if nargin < 3 || isempty(Y_init_frac), Y_init_frac = 0.9; end

    C_bar = getf(params,'C_bar',0.6);  I_bar = getf(params,'I_bar',0.2);
    c     = getf(params,'c',    0.5);  alpha = getf(params,'alpha',0.1);
    b     = getf(params,'b',    0.1);
    G     = getf(params,'G',    1.7);  T_tax = getf(params,'T',1.7);
    i_r   = getf(params,'i',    0.04);

    rho   = c + alpha;
    kappa = C_bar + I_bar + G - c*T_tax - b*i_r;

    Y_ss = kappa / (1 - rho);
    C_ss = C_bar + c*(Y_ss - T_tax);
    I_ss = I_bar + alpha*Y_ss - b*i_r;

    N    = T_sim + 1;
    Y    = zeros(N,1);
    Y(1) = Y_init_frac * Y_ss;   % Y_{-1}
    for t = 2:N
        Y(t) = rho * Y(t-1) + kappa;
    end

    % ── FIX: C_t and I_t use Y_{t-1}, not Y_t 
    % Y(k) is output at period k-2 (t axis: -1, 0, 1, ..., T_sim-1)
    % C_t uses Y_{t-1} = Y(k-1)   →  [Y(1); Y(1:end-1)]
    Y_lag = [Y(1); Y(1:end-1)];
    C = C_bar + c*(Y_lag - T_tax);
    I = I_bar + alpha*Y_lag - b*i_r;

    if rho > 0 && rho < 1
        half_life = -log(2)/log(rho);
    else
        half_life = Inf;
    end

    sim.Y         = Y;
    sim.C         = C;
    sim.I         = I;
    sim.Y_ss      = Y_ss;
    sim.C_ss      = C_ss;
    sim.I_ss      = I_ss;
    sim.rho       = rho;
    sim.kappa     = kappa;
    sim.half_life = half_life;
    sim.t         = (-1 : T_sim-1)';
    sim.params    = params;
end




function result = compute_policy_shock(params_old, params_new, T_sim, gamma)
% Permanent policy shock: old SS -> transition -> new SS

    if nargin < 3 || isempty(T_sim), T_sim = 40;  end
    if nargin < 4 || isempty(gamma), gamma = 0.7; end

    [Cbo,Ibo,co,ao,bo,Go,To,io] = unpack(params_old);
    [Cbn,Ibn,cn,an,bn,Gn,Tn,in_] = unpack(params_new);

    ss_old = ss_compute(Cbo,Ibo,co,ao,bo,Go,To,io,gamma);
    ss_new = ss_compute(Cbn,Ibn,cn,an,bn,Gn,Tn,in_,gamma);

    N = T_sim + 1;
    Y = zeros(N,1);
    Y(1) = ss_old.Y;   % initial condition = old SS

    % Fix: correct lag structure for T and i shocks 
    % G enters current period → new kappa applies immediately (k>=2, t>=0)
    % T_{t-1} and i_{t-1} enter with ONE lag:
    %   shock at t=1 means first effect on Y at t=2 (k=4 in our indexing)
    %   k=1 → t=-1 (given), k=2 → t=0, k=3 → t=1, k=4 → t=2
    T_changed = (Tn ~= To);
    i_changed = (in_ ~= io);

    for k = 2:N
        if (T_changed || i_changed) && k <= 3
            % k=2 (t=0): T_{-1}=old, i_{-1}=old → old kappa
            % k=3 (t=1): T_0  =old, i_0  =old → old kappa still
            Y(k) = ss_new.rho * Y(k-1) + ss_old.kappa;
        else
            % G shock or t>=2: new kappa applies
            Y(k) = ss_new.rho * Y(k-1) + ss_new.kappa;
        end
    end

    % Fix: C and I use lagged Y (Y_{t-1})
    Y_lag = [Y(1); Y(1:end-1)];
    C = Cbn + cn*(Y_lag - Tn);
    I = Ibn + an*Y_lag - bn*in_;
    L = gamma * Y;

    result.t        = (-1 : T_sim-1)';
    result.Y        = Y;
    result.C        = C;
    result.I        = I;
    result.L        = L;
    result.ss_old   = ss_old;
    result.ss_new   = ss_new;
    result.delta_ss = struct('Y',ss_new.Y-ss_old.Y, 'C',ss_new.C-ss_old.C, ...
                             'I',ss_new.I-ss_old.I, 'L',ss_new.L-ss_old.L);
    result.params_old = params_old;
    result.params_new = params_new;
end

function sim = simulate_transitory(base_params, shock_var, shock_size, ...
                                   rho_shock, T_sim, gamma, balanced_budget)
% Transitory AR(1) policy shock starting from steady state.
%   shock_var       : 'G' | 'T' | 'i'
%   shock_size      : for 'G','T' fractional (0.10=10%); for 'i' absolute (e.g. 0.0075)
%   rho_shock       : AR(1) persistence in [0,1)
%   balanced_budget : (only for 'G') if true, T_t = G_t

    if nargin < 6, gamma = 0.7; end
    if nargin < 7, balanced_budget = false; end

    C_bar = base_params.C_bar;  I_bar = base_params.I_bar;
    c     = base_params.c;      alpha = base_params.alpha;
    b     = base_params.b;
    G_ss  = base_params.G;      T_ss  = base_params.T;
    i_ss  = base_params.i;

    rho_model = c + alpha;
    kappa_ss  = C_bar + I_bar + G_ss - c*T_ss - b*i_ss;
    Y_ss = kappa_ss / (1 - rho_model);
    C_ss = C_bar + c*(Y_ss - T_ss);
    I_ss = I_bar + alpha*Y_ss - b*i_ss;

    % Build policy paths G_t, T_t, i_t for t = 1..T_sim
    G_path = G_ss * ones(T_sim, 1);
    T_path = T_ss * ones(T_sim, 1);
    i_path = i_ss * ones(T_sim, 1);

    switch shock_var
        case 'G'
            G_path(1) = (1 + shock_size) * G_ss;
            for t = 2:T_sim
                G_path(t) = G_ss + rho_shock*(G_path(t-1) - G_ss);
            end
            if balanced_budget
                T_path = G_path;   % T_t = G_t
            end
        case 'T'
            T_path(1) = (1 + shock_size) * T_ss;
            for t = 2:T_sim
                T_path(t) = T_ss + rho_shock*(T_path(t-1) - T_ss);
            end
        case 'i'
            i_path(1) = i_ss + shock_size;   % absolute shock (e.g. 0.0075)
            for t = 2:T_sim
                i_path(t) = i_ss + rho_shock*(i_path(t-1) - i_ss);
            end
    end

    % Lagged policy for model equations (T_{t-1}, i_{t-1} for t=1..T_sim)
    % T_0 = T_ss (initial), T_{t-1} = T_path(t-1) for t>=2
    T_lag = [T_ss; T_path(1:end-1)];
    i_lag = [i_ss; i_path(1:end-1)];

    % Kappa at each period t=1..T_sim
    kappa_vec = C_bar + I_bar + G_path - c*T_lag - b*i_lag;

    % Simulate Y for t=0..T_sim (N=T_sim+1 points), Y(1)=Y_ss at t=0
    N = T_sim + 1;
    Y = zeros(N,1);
    Y(1) = Y_ss;
    for k = 2:N
        Y(k) = rho_model * Y(k-1) + kappa_vec(k-1);
    end

    % C and I with correct lag (C_t uses Y_{t-1} and T_{t-1})
    % At t=0: C_0 = C_ss (pre-shock), then C_t = C_bar+c*(Y_{t-1}-T_{t-1})
    C = [C_ss; C_bar + c*(Y(1:end-1) - T_lag)];
    I = [I_ss; I_bar + alpha*Y(1:end-1) - b*i_lag];
    L = gamma * Y;

    % Output struct (t=0..T_sim)
    sim.t        = (0:T_sim)';
    sim.Y        = Y;
    sim.C        = C;
    sim.I        = I;
    sim.L        = L;
    sim.G_path   = [G_ss; G_path];
    sim.T_path   = [T_ss; T_path];
    sim.i_path   = [i_ss; i_path];
    sim.Y_ss     = Y_ss;
    sim.C_ss     = C_ss;
    sim.I_ss     = I_ss;
    sim.L_ss     = gamma * Y_ss;
    sim.rho      = rho_shock;
    sim.shock_var = shock_var;
    sim.balanced_budget = balanced_budget;
end



function plot_single_transition(sim, fig_title)
    vars_p  = {'Y','C','I'};
    ss_p    = {'Y_ss','C_ss','I_ss'};
    names_p = {'Output  Y_t','Consumption  C_t','Investment  I_t'};
    c_line  = [0.15 0.44 0.73];
    c_ss    = [0.84 0.15 0.16];

    fig = figure('Name',['Transition — ' fig_title],'NumberTitle','off',...
                 'Position',[100 120 1100 360]);
    for v = 1:3
        ax  = subplot(1,3,v);
        y_v = sim.(vars_p{v});
        yss = sim.(ss_p{v});
        t   = sim.t;
        fill(ax,[t;flipud(t)],[y_v;yss*ones(size(y_v))],...
             c_line,'FaceAlpha',0.12,'EdgeColor','none');
        hold(ax,'on');
        yline(ax,yss,'--','Color',c_ss,'LineWidth',1.5,...
              'DisplayName',sprintf('SS = %.4f',yss));
        plot(ax,t,y_v,'-o','Color',c_line,'LineWidth',1.8,...
             'MarkerFaceColor',c_line,'MarkerSize',3.5,...
             'DisplayName',names_p{v});
        plot(ax,t(1),y_v(1),'ks','MarkerFaceColor',[0.9 0.7 0.1],...
             'MarkerSize',7,'DisplayName',sprintf('t_{-1}=%.4f',y_v(1)));
        xlabel(ax,'Period','FontSize',10); ylabel(ax,names_p{v},'FontSize',10);
        title(ax,names_p{v},'FontSize',11,'FontWeight','bold');
        legend(ax,'Location','southeast','FontSize',8,'Box','off');
        grid(ax,'on'); box(ax,'on'); set(ax,'FontSize',9,'GridAlpha',0.22);
        xlim(ax,[t(1)-0.3, t(end)]);
    end
    sgtitle(fig,sprintf('%s  |  Y^*=%.4f  |  \\rho=%.2f  |  Half-life=%.2f', ...
            fig_title, sim.Y_ss, sim.rho, sim.half_life),...
            'FontSize',12,'FontWeight','bold');
end









%  Utility helpers

function val = getf(s, field, default)
    if isfield(s, field), val = s.(field); else, val = default; end
end

function ss = ss_compute(C_bar, I_bar, c, alpha, b, G, T_tax, i, gamma)
    rho   = c + alpha;
    kappa = C_bar + I_bar + G - c*T_tax - b*i;
    Y     = kappa / (1 - rho);
    ss    = struct('Y',Y, 'C',C_bar+c*(Y-T_tax), 'I',I_bar+alpha*Y-b*i, ...
                   'L',gamma*Y, 'rho',rho, 'kappa',kappa);
end

function [C_bar,I_bar,c,alpha,b,G,T_tax,i] = unpack(p)
    C_bar=p.C_bar; I_bar=p.I_bar; c=p.c; alpha=p.alpha;
    b=p.b; G=p.G; T_tax=p.T; i=p.i;
end
