from rest_framework import serializers
from .models import MetaDiaria, RegistroAgua, RegistroExercicio, RegistroSono, RegistroRefeicao

class MetaDiariaSerializer(serializers.ModelSerializer):
    class Meta:
        model = MetaDiaria
        fields = '__all__' 
        read_only_fields = ['user']

class RegistroAguaSerializer(serializers.ModelSerializer):
    class Meta:
        model = RegistroAgua
        fields = '__all__'
        read_only_fields = ['user']

class RegistroExercicioSerializer(serializers.ModelSerializer):
    class Meta:
        model = RegistroExercicio
        fields = '__all__'
        read_only_fields = ['user']

class RegistroSonoSerializer(serializers.ModelSerializer):
    class Meta:
        model = RegistroSono
        fields = '__all__'
        read_only_fields = ['user']

class RegistroRefeicaoSerializer(serializers.ModelSerializer):
    class Meta:
        model = RegistroRefeicao
        fields = '__all__'
        read_only_fields = ['user']