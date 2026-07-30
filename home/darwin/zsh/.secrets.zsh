if [[ -f "$HOME/.secrets" ]]; then
  while IFS='=' read -r env_var keychain_name || [[ -n "$env_var" ]]; do
    [[ -z "$env_var" || "$env_var" =~ ^[[:space:]]*# || -z "$keychain_name" ]] && continue
    
    env_var="${${env_var##*( )}%%*( )}"
    keychain_name="${${keychain_name##*( )}%%*( )}"
    
    secret_value=$(security find-generic-password -a "$USER" -s "$keychain_name" -w 2>/dev/null)

    if [[ $? -eq 0 && -n "$secret_value" ]]; then
      export "$env_var"="$secret_value"
      unset secret_value
    fi
  done < "$HOME/.secrets"
fi
