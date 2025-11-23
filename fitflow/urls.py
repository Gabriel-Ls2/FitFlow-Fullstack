from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse
from rest_framework.routers import DefaultRouter
from core.views import  MetaDiariaViewSet, RegistroAguaViewSet, RegistroExercicioViewSet, RegistroSonoViewSet, RegistroRefeicaoViewSet, dashboard_data, progress_data, solicitar_codigo_senha, verificar_codigo_e_mudar_senha


# --- CONFIGURAÇÃO DA API (ROUTER) ---
router = DefaultRouter()
router.register(r'metas', MetaDiariaViewSet)
router.register(r'agua', RegistroAguaViewSet)
router.register(r'exercicios', RegistroExercicioViewSet)
router.register(r'sono', RegistroSonoViewSet)
router.register(r'refeicoes', RegistroRefeicaoViewSet)

# --- FUNÇÃO FALSA PARA O LINK DO EMAIL ---
def password_reset_confirm_placeholder(request, uidb64, token):
    return HttpResponse(f"Link de redefinição recebido!<br>UID: {uidb64}<br>Token: {token}")

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # Rotas de Autenticação (Login, Logout, Cadastro, Senha)
    path('api/auth/', include('dj_rest_auth.urls')), 
    path('api/auth/registration/', include('dj_rest_auth.registration.urls')),
    path('password-reset/confirm/<uidb64>/<token>/', password_reset_confirm_placeholder, name='password_reset_confirm'),
    path('api/password/request-code/', solicitar_codigo_senha),
    path('api/password/verify-change/', verificar_codigo_e_mudar_senha),

    # (Dashboard, Gráficos, CRUDs)
    path('api/', include(router.urls)),
    path('api/dashboard/', dashboard_data),
    path('api/progress/', progress_data),
]