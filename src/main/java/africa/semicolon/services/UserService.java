package africa.semicolon.services;

import africa.semicolon.dto.request.RegisterRequest;
import africa.semicolon.dto.response.RegisterResponse;

public interface UserService {
    RegisterResponse register(RegisterRequest request);
}
