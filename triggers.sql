-- Trigger: criar perfil ao registrar novo usuário
CREATE TRIGGER trg_ao_criar_usuario_auth
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.fn_tratar_novo_usuario();

-- Triggers: manter atualizado automaticamente
CREATE TRIGGER trg_perfis_atualizado_em
    BEFORE UPDATE ON public.perfis
    FOR EACH ROW EXECUTE FUNCTION public.fn_definir_atualizado_em();

CREATE TRIGGER trg_escolas_atualizado_em
    BEFORE UPDATE ON public.escolas
    FOR EACH ROW EXECUTE FUNCTION public.fn_definir_atualizado_em();

CREATE TRIGGER trg_questoes_atualizado_em
    BEFORE UPDATE ON public.questoes
    FOR EACH ROW EXECUTE FUNCTION public.fn_definir_atualizado_em();

-- Trigger: validar admin ao criar/atualizar escola
CREATE TRIGGER trg_validar_admin_escola
    BEFORE INSERT OR UPDATE OF admin_id ON public.escolas
    FOR EACH ROW EXECUTE FUNCTION public.fn_validar_papel_admin_escola();

-- Trigger: validar aluno ao matricular
CREATE TRIGGER trg_validar_matricula_aluno
    BEFORE INSERT ON public.matriculas
    FOR EACH ROW EXECUTE FUNCTION public.fn_validar_papel_aluno();

-- Trigger: atualizar contadores da sessão
CREATE TRIGGER trg_atualizar_estatisticas_sessao
    AFTER INSERT ON public.respostas
    FOR EACH ROW EXECUTE FUNCTION public.fn_atualizar_estatisticas_sessao();

-- Trigger: bloquear respostas
CREATE TRIGGER trg_impedir_resposta_sessao_concluida
    BEFORE INSERT ON public.respostas
    FOR EACH ROW EXECUTE FUNCTION public.fn_impedir_resposta_sessao_concluida();