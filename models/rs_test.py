exptable = (1, 2, 4, 8, 16, 32, 64, 128, 29, 58, 116, 232, 205, 135, 19, 38,
                 76, 152, 45, 90, 180, 117, 234, 201, 143, 3, 6, 12, 24, 48, 96,
                 192, 157, 39, 78, 156, 37, 74, 148, 53, 106, 212, 181, 119, 238,
                 193, 159, 35, 70, 140, 5, 10, 20, 40, 80, 160, 93, 186, 105, 210,
                 185, 111, 222, 161, 95, 190, 97, 194, 153, 47, 94, 188, 101, 202,
                 137, 15, 30, 60, 120, 240, 253, 231, 211, 187, 107, 214, 177, 127,
                 254, 225, 223, 163, 91, 182, 113, 226, 217, 175, 67, 134, 17, 34,
                 68, 136, 13, 26, 52, 104, 208, 189, 103, 206, 129, 31, 62, 124, 248,
                 237, 199, 147, 59, 118, 236, 197, 151, 51, 102, 204, 133, 23, 46,
                 92, 184, 109, 218, 169, 79, 158, 33, 66, 132, 21, 42, 84, 168, 77,
                 154, 41, 82, 164, 85, 170, 73, 146, 57, 114, 228, 213, 183, 115,
                 230, 209, 191, 99, 198, 145, 63, 126, 252, 229, 215, 179, 123, 246,
                 241, 255, 227, 219, 171, 75, 150, 49, 98, 196, 149, 55, 110, 220,
                 165, 87, 174, 65, 130, 25, 50, 100, 200, 141, 7, 14, 28, 56, 112,
                 224, 221, 167, 83, 166, 81, 162, 89, 178, 121, 242, 249, 239, 195,
                 155, 43, 86, 172, 69, 138, 9, 18, 36, 72, 144, 61, 122, 244, 245,
                 247, 243, 251, 235, 203, 139, 11, 22, 44, 88, 176, 125, 250, 233,
                 207, 131, 27, 54, 108, 216, 173, 71, 142, 1)

# Logarithm table,for 0x11D
logtable = (None, 0, 1, 25, 2, 50, 26, 198, 3, 223, 51, 238, 27, 104, 199, 75, 4,
                 100, 224, 14, 52, 141, 239, 129, 28, 193, 105, 248, 200, 8, 76, 113, 5,
                 138, 101, 47, 225, 36, 15, 33, 53, 147, 142, 218, 240, 18, 130, 69, 29,
                 181, 194, 125, 106, 39, 249, 185, 201, 154, 9, 120, 77, 228, 114, 166,
                 6, 191, 139, 98, 102, 221, 48, 253, 226, 152, 37, 179, 16, 145, 34, 136,
                 54, 208, 148, 206, 143, 150, 219, 189, 241, 210, 19, 92, 131, 56, 70, 64,
                 30, 66, 182, 163, 195, 72, 126, 110, 107, 58, 40, 84, 250, 133, 186,
                 61, 202, 94, 155, 159, 10, 21, 121, 43, 78, 212, 229, 172, 115, 243,
                 167, 87, 7, 112, 192, 247, 140, 128, 99, 13, 103, 74, 222, 237, 49, 197,
                 254, 24, 227, 165, 153, 119, 38, 184, 180, 124, 17, 68, 146, 217, 35, 32,
                 137, 46, 55, 63, 209, 91, 149, 188, 207, 205, 144, 135, 151, 178, 220,
                 252, 190, 97, 242, 86, 211, 171, 20, 42, 93, 158, 132, 60, 57, 83, 71,
                 109, 65, 162, 31, 45, 67, 216, 183, 123, 164, 118, 196, 23, 73, 236, 127,
                 12, 111, 246, 108, 161, 59, 82, 41, 157, 85, 170, 251, 96, 134, 177, 187,
                 204, 62, 90, 203, 89, 95, 176, 156, 169, 160, 81, 11, 245, 22, 235, 122,
                 117, 44, 215, 79, 174, 213, 233, 230, 231, 173, 232, 116, 214, 244, 234,
                 168, 80, 88, 175)



class ReedSolomonGF:
    def __init__(self, prim_poly=0x11D, field_charac=256):
        """
        Initialize Galois Field arithmetic

        Args:
        prim_poly (int): Primitive polynomial for the field
        field_charac (int): Field characteristic (256 for 8-bit symbols)
        """
        self.prim_poly = prim_poly
        self.field_charac = field_charac

        # Precompute logarithm and antilogarithm tables
        #self.log_table = [0] * field_charac
        #self.alog_table = [0] * field_charac
        self.log_table = logtable
        self.alog_table = exptable
        #x = 1
        #for i in range(field_charac - 1):
        #    self.log_table[x] = i
        #    self.alog_table[i] = x
        #    x = self.gf_mult(x, 2)

    def gf_add(self, a, b):
        """Galois Field addition (XOR)"""
        return a ^ b

    def gf_poly_div(self, dividend, divisor):
        '''Fast polynomial division by using Extended Synthetic Division and optimized for GF(2^p) computations
        (doesn't work with standard polynomials outside of this galois field, see the Wikipedia article for generic algorithm).'''
        # CAUTION: this function expects polynomials to follow the opposite convention at decoding:
        # the terms must go from the biggest to lowest degree (while most other functions here expect
        # a list from lowest to biggest degree). eg: 1 + 2x + 5x^2 = [5, 2, 1], NOT [1, 2, 5]

        msg_out = list(dividend)  # Copy the dividend
        # normalizer = divisor[0] # precomputing for performance
        for i in range(0, len(dividend) - (len(divisor) - 1)):
            # msg_out[i] /= normalizer # for general polynomial division (when polynomials are non-monic), the usual way of using
            # synthetic division is to divide the divisor g(x) with its leading coefficient, but not needed here.
            coef = msg_out[i]  # precaching
            if coef != 0:  # log(0) is undefined, so we need to avoid that case explicitly (and it's also a good optimization).
                for j in range(1, len(
                        divisor)):  # in synthetic division, we always skip the first coefficient of the divisior,
                    # because it's only used to normalize the dividend coefficient
                    if divisor[j] != 0:  # log(0) is undefined
                        msg_out[i + j] ^= self.gf_mult(divisor[j], coef)  # equivalent to the more mathematically correct
                        # (but xoring directly is faster): msg_out[i + j] += -divisor[j] * coef

        # The resulting msg_out contains both the quotient and the remainder, the remainder being the size of the divisor
        # (the remainder has neces sarily the same degree as the divisor -- not length but degree == length-1 -- since it's
        # what we couldn't divide from the dividend), so we compute the index where this separation is, and return the quotient and remainder.
        separator = -(len(divisor) - 1)
        return msg_out[:separator], msg_out[separator:]

    def gf_poly_mult(self,p, q):
        '''Multiply two polynomials, inside Galois Field'''
        # Pre-allocate the result array
        r = [0] * (len(p) + len(q) - 1)
        # Compute the polynomial multiplication (just like the outer product of two vectors,
        # we multiply each coefficients of p with all coefficients of q)
        for j in range(0, len(q)):
            for i in range(0, len(p)):
                r[i + j] ^= self.gf_mult(p[i], q[j])  # equivalent to: r[i + j] = gf_add(r[i+j], gf_mul(p[i], q[j]))
                # -- you can see it's your usual polynomial multiplication
        return r
    def gf_poly_scale(self, p, x):
        r = [0] * len(p)
        for i in range(0, len(p)):
            r[i] =  self.gf_mult(p[i], x)
        return r

    def gf_poly_add(self, p, q):
        r = [0] * max(len(p), len(q))
        for i in range(0, len(p)):
            r[i + len(r) - len(p)] = p[i]
        for i in range(0, len(q)):
            r[i + len(r) - len(q)] ^= q[i]
        return r

    def gf_inverse(self, x):
        return self.alog_table[255 - self.log_table[x]]

    def gf_mult_no_lut(self,in1 ,in2):
        '''  https://github.com/oliviercotte/Reed-Solomon/blob/master/spec/src/general_RS.c   '''
        A0 = in1 & 0x1
        B0 = in2 & 0x1
        A1 = (in1 >> 1) & 0x1
        B1 = (in2 >> 1) & 0x1
        A2 = (in1 >> 2) & 0x1
        B2 = (in2 >> 2) & 0x1
        A3 = (in1 >> 3) & 0x1
        B3 = (in2 >> 3) & 0x1
        A4 = (in1 >> 4) & 0x1
        B4 = (in2 >> 4) & 0x1
        A5 = (in1 >> 5) & 0x1
        B5 = (in2 >> 5) & 0x1
        A6 = (in1 >> 6) & 0x1
        B6 = (in2 >> 6) & 0x1
        A7 = (in1 >> 7) & 0x1
        B7 = (in2 >> 7) & 0x1

        Z0 = (B0 & A0) ^ (B1 & A7) ^ (B2 & A6) ^ (B3 & A5) ^ (B4 & A4) ^ (B5 & A3) ^ (B5 & A7) ^ (B6 & A2) ^ (
                    B6 & A6) ^ (B6 & A7) ^ (B7 & A1) ^ (B7 & A5) ^ (B7 & A6) ^ (B7 & A7);

        Z1 = (B0 & A1) ^ (B1 & A0) ^ (B2 & A7) ^ (B3 & A6) ^ (B4 & A5) ^ (B5 & A4) ^ (B6 & A3) ^ (B6 & A7) ^ (
                    B7 & A2) ^ (B7 & A6) ^ (B7 & A7);

        Z2 = (B0 & A2) ^ (B1 & A1) ^ (B1 & A7) ^ (B2 & A0) ^ (B2 & A6) ^ (B3 & A5) ^ (B3 & A7) ^ (B4 & A4) ^ (
                    B4 & A6) ^ (B5 & A3) ^ (B5 & A5) ^ (B5 & A7) ^ (B6 & A2) ^ (B6 & A4) ^ (B6 & A6) ^ (B6 & A7) ^ (
                         B7 & A1) ^ (B7 & A3) ^ (B7 & A5) ^ (B7 & A6);

        Z3 = (B0 & A3) ^ (B1 & A2) ^ (B1 & A7) ^ (B2 & A1) ^ (B2 & A6) ^ (B2 & A7) ^ (B3 & A0) ^ (B3 & A5) ^ (
                    B3 & A6) ^ (B4 & A4) ^ (B4 & A5) ^ (B4 & A7) ^ (B5 & A3) ^ (B5 & A4) ^ (B5 & A6) ^ (B5 & A7) ^ (
                         B6 & A2) ^ (B6 & A3) ^ (B6 & A5) ^ (B6 & A6) ^ (B7 & A1) ^ (B7 & A2) ^ (B7 & A4) ^ (B7 & A5);

        Z4 = (B0 & A4) ^ (B1 & A3) ^ (B1 & A7) ^ (B2 & A2) ^ (B2 & A6) ^ (B2 & A7) ^ (B3 & A1) ^ (B3 & A5) ^ (
                    B3 & A6) ^ (B3 & A7) ^ (B4 & A0) ^ (B4 & A4) ^ (B4 & A5) ^ (B4 & A6) ^ (B5 & A3) ^ (B5 & A4) ^ (
                         B5 & A5) ^ (B6 & A2) ^ (B6 & A3) ^ (B6 & A4) ^ (B7 & A1) ^ (B7 & A2) ^ (B7 & A3) ^ (B7 & A7);

        Z5 = (B0 & A5) ^ (B1 & A4) ^ (B2 & A3) ^ (B2 & A7) ^ (B3 & A2) ^ (B3 & A6) ^ (B3 & A7) ^ (B4 & A1) ^ (
                    B4 & A5) ^ (B4 & A6) ^ (B4 & A7) ^ (B5 & A0) ^ (B5 & A4) ^ (B5 & A5) ^ (B5 & A6) ^ (B6 & A3) ^ (
                         B6 & A4) ^ (B6 & A5) ^ (B7 & A2) ^ (B7 & A3) ^ (B7 & A4);

        Z6 = (B0 & A6) ^ (B1 & A5) ^ (B2 & A4) ^ (B3 & A3) ^ (B3 & A7) ^ (B4 & A2) ^ (B4 & A6) ^ (B4 & A7) ^ (
                    B5 & A1) ^ (B5 & A5) ^ (B5 & A6) ^ (B5 & A7) ^ (B6 & A0) ^ (B6 & A4) ^ (B6 & A5) ^ (B6 & A6) ^ (
                         B7 & A3) ^ (B7 & A4) ^ (B7 & A5);

        Z7 = (B0 & A7) ^ (B1 & A6) ^ (B2 & A5) ^ (B3 & A4) ^ (B4 & A3) ^ (B4 & A7) ^ (B5 & A2) ^ (B5 & A6) ^ (
                    B5 & A7) ^ (B6 & A1) ^ (B6 & A5) ^ (B6 & A6) ^ (B6 & A7) ^ (B7 & A0) ^ (B7 & A4) ^ (B7 & A5) ^ (
                         B7 & A6);

        Z = Z0;
        Z |= (Z1 << 1);
        Z |= (Z2 << 2);
        Z |= (Z3 << 3);
        Z |= (Z4 << 4);
        Z |= (Z5 << 5);
        Z |= (Z6 << 6);
        Z |= (Z7 << 7);

        return Z;

    def gf_mult(self, a, b):
        """Galois Field multiplication"""
        if a == 0 or b == 0:
            return 0
        return self.alog_table[(self.log_table[a] + self.log_table[b]) % 255]

    def gf_div(self, a, b):
        """Galois Field division"""
        if b == 0:
            raise ZeroDivisionError("Division by zero in Galois Field")

        if a == 0:
            return 0

        return self.alog_table[
            (self.log_table[a] - self.log_table[b] + (self.field_charac - 1)) % (self.field_charac - 1)]

    def gf_poly_eval(self, poly, x):
        '''Evaluates a polynomial in GF(2^p) given the value for x. This is based on Horner's scheme for maximum efficiency.'''
        y = poly[0]
        for i in range(1, len(poly)):
            temp1= self.gf_mult(y, x)
            temp2= poly[i]
            y=temp1 ^ temp2
            #y = self.gf_mult(y, x) ^ poly[i]
        return y


    def gf_pow(self, base, exp):
        """Galois Field power"""
        if exp == 0:
            return 1
        if base == 0:
            return 0

        return self.alog_table[(self.log_table[base] * exp) % (self.field_charac - 1)]


class ReedSolomon:
    def __init__(self, field, n, k, t):
        """
        Initialize Reed-Solomon Encoder/Decoder

        Args:
        field (ReedSolomonGF): Galois Field arithmetic object
        n (int): Codeword length
        k (int): Message length
        t (int): Error-correction capability
        """
        self.field = field
        self.n = n  # Total codeword length
        self.k = k  # Message length
        self.t = t  # Error-correction capability

    def calculate_syndromes(self, received_msg):
        k = 0
        syndromes = [0, 0, 0, 0]
        alpha_j = [1,2,4,8]
        for byte in received_msg:
            for i in range(4):
                k= alpha_j[i]
                syndromes[i] = self.field.gf_add(self.field.gf_mult(syndromes[i], alpha_j[i]), byte)
        print(syndromes)
        #return syndromes
        return [0] + [self.field.gf_poly_eval(received_msg, self.field.gf_pow(2, i)) for i in xrange(4)]

    def ribm2(self, syndrome):
        """
        Reformulated inversionless Berlekamp-Massey algorithm for Reed-Solomon decoding

        Parameters:
            syndrome (list): Input syndrome values
            t (int): Error correction capability
            m (int): Field size parameter (default: 8 for GF(2^8))
            primitive_poly (int): Primitive polynomial for Galois Field (default: 0x11D)

        Returns:
            tuple: (omega, lambda) - error evaluator and error locator polynomials
        """
        t = 2
        # Initialize arrays
        delta = [0] * (3 * t + 2)  # Length 3*t+2
        delta[3 * t] = 1  # Set the 1 at position 3*t
        delta[3 * t + 1] = 0  # Last element is 0

        theta = [0] * (3 * t + 1)  # Length 3*t+1
        theta[3 * t] = 1  # Set the 1 at the end

        gamma = 1
        k = 0
        synd = syndrome[::-1]
        # Initialize with syndromes
        for i in range(2 * t):
            if i < len(synd):
                delta[i] = synd[i]
                theta[i] = synd[i]

        # Main algorithm loop - run 2*t+1 iterations
        for _ in range(2 * t  ):
            # Store current delta
            delta_0 = delta[:]

            # Step RiBM.1: Calculate the next delta
            # term1 = gamma * delta_0(2:3*t+2)
            term1 = self.field.gf_poly_scale(delta_0[1:3 * t + 2], gamma)

            # term2 = delta_0(1) * theta
            term2 = self.field.gf_poly_scale(theta, delta_0[0])

            # New delta = term1 - term2 (XOR in GF)
            new_delta = self.field.gf_poly_add(term1, term2)

            # Update delta (first 3*t+1 elements)
            for i in range(len(new_delta)):
                if i < 3 * t + 1:
                    delta[i] = new_delta[i]
            delta[3 * t + 1] = 0  # Ensure last element is 0
            print(" ribm2 " + "  " + str(new_delta))
            # Step RiBM.2: Conditional update
            if delta_0[0] != 0 and k >= 0:
                # Update theta to shifted delta_0
                for i in range(3 * t):
                    theta[i] = delta_0[i + 1]
                theta[3 * t] = 0

                gamma = delta_0[0]
                k = -k - 1
            else:
                k = k + 1

        # Extract results
        sigma = delta[(t):2 * t +1][::-1]  # reverse order
        # Error evaluator polynomial: first t elements (2 elements for t=2)
        omega = delta[0:t][::-1]  # reverse order

        return sigma, omega

    def ribm(self, syndrome):
        t = 2
        k = 0
        gamma = 1
        n = 3 * t + 2  # Total length = 8 for t=2

        # Initialize delta: syndrome in first 2*t positions, 1 at index 3*t
        delta = [0] * n
        synd = syndrome[::-1]
        for i in range(2 * t):
            delta[i] = synd[i]
        delta[3 * t] = 1

        # Theta = first 3*t+1 elements of delta
        theta = delta[:3 * t + 1]  # Length 7
        delta_next = delta[:]  # Copy

        # Run 2*t+1 iterations (5 times for t=2)
        for r in range(2 * t + 1):
            # Store current state
            current_delta = delta_next[:]

            # Step 1: Compute next delta segment (first 3*t+1 elements)
            # term1 = gamma * (current_delta shifted left by 1)
            term1 = self.field.gf_poly_scale(current_delta[1:3 * t + 2], gamma)
            # term2 = current_delta[0] * theta
            term2 = self.field.gf_poly_scale(theta, current_delta[0])
            # New segment = term1 - term2 (GF addition)
            new_segment = self.field.gf_poly_add(term1, term2)

            # Ensure proper length (3*t+1 elements)
            #if len(new_segment) < 3 * t + 1:
            #    new_segment += [0] * (3 * t + 1 - len(new_segment))

            # Update delta_next: new_segment + last element of current_delta
            delta_next = new_segment + [current_delta[-1]]
            print(" ribm " + str(r) + "  "  + str(delta_next))
            # Step 2: Conditional update
            if current_delta[0] != 0 and k >= 0:
                # Update theta to shifted current_delta (drop first element)
                theta = current_delta[1:3 * t + 2]  # Should be 3*t+1 elements
                gamma = current_delta[0]
                k = -k - 1
            else:
                k += 1

        # Extract results from FINAL current_delta (after last iteration)
        # Error locator polynomial: indices t to 2*t (3 elements for t=2)
        sigma = current_delta[t:2 * t + 1][::-1] #reverse order
        # Error evaluator polynomial: first t elements (2 elements for t=2)
        omega = current_delta[0:t][::-1] #reverse order

        return sigma, omega

    def berlekamp_massey2(self, syndromes):
        """
        [IB] improved BM from CG more like in the book
        Berlekamp-Massey algorithm with debug output.
        Args:
            syndromes: List of syndromes [S1, S2, ..., S2t]
        Returns:
            sigma: Error locator polynomial
            omega: Error evaluator polynomial
        """

        n = len(syndromes)
        sigma = [1]
        old_sigma = [1]
        L = 0
        m = -1
        b = 1

        print("Starting Berlekamp-Massey")
        for i in range(n):
            # Compute discrepancy
            #print("BM interation " + str(i))
            d = syndromes[i]
            for j in range(1, L + 1):
                if j < len(sigma) and (i - j) >= 0:
                    d = self.field.gf_add(d, self.field.gf_mult(sigma[j], syndromes[i - j]))
                    #print("j  " , str(j) , "i-j " , str(i-j))
                    #print(" d " + str(d))

            #print(" outer loop d " + str(d))
            if d == 0:
                sigma.append(0)  # Just increase the degree
                print("  Discrepancy zero, just appending 0 to sigma.")
            else:
                # Save current sigma before updating
                sigma_copy = sigma[:]

                # Scale and align old_sigma
                scale = self.field.gf_poly_scale(old_sigma, self.field.gf_div(d, b))
                scale = [0] * (i - m) + scale
                #print(" scale " + str(scale))
                if len(scale) > len(sigma):
                    sigma += [0] * (len(scale) - len(sigma))
                else:
                    scale += [0] * (len(sigma) - len(scale))
                sigma = self.field.gf_poly_add(sigma, scale)
                #print(" sigma " + str(sigma))
                #print(" 2L<i " + str(2*L) + "<= " + str(i))
                #print(" old_sigma " + str(old_sigma))
                if 2 * L <= i:
                    #print(" old L " + str(L))
                    L = i + 1 - L
                    old_sigma = sigma_copy  # update AFTER the new sigma is formed
                    b = d
                    m = i
                    #print(" new L " + str(L))
                    #print(" old_sigma " + str(old_sigma))
                    #print(" b " + str(b))
                    #print(" m " + str(m))
                    #print("  Length L updated.")

        # Compute omega = syndrome(x) * sigma(x) mod x^(2t)
        omega = self.field.gf_poly_mult(syndromes, sigma)
        omega = omega[:n]  # Truncate to degree < 2t

        print ("BM2 sigma" + str(sigma))
        print ("BM2 omega" + str(omega))

        return sigma, omega

    def berlekamp_massey(self, syndromes):
        err_loc = [1]
        old_loc = [1]
        nsym = 4
        synd_shift = len(syndromes) - nsym
        K=0
        for i in range(0, nsym):  # generally: nsym-erase_count == len(synd), except when you input a partial erase_loc and using the full syndrome instead of the Forney syndrome, in which case nsym-erase_count is more correct (len(synd) will fail badly with IndexError).
            K = i + synd_shift

            delta = syndromes[K]
            for j in range(1, len(err_loc)):
                print ("BM syndromes[K - j] " + str(syndromes[K - j]))
                print ("BM err_loc[-j-1] " + str(err_loc[-(j + 1)]))

                delta ^= self.field.gf_mult(err_loc[-(j + 1)], syndromes[K - j])  # delta is also called discrepancy. Here we do a partial polynomial multiplication (ie, we compute the polynomial multiplication only for the term of degree K). Should be equivalent to brownanrs.polynomial.mul_at().
                # print "delta", K, delta, list(gf_poly_mul(err_loc[::-1], synd)) # debugline
                print ("BM delta  " + str(delta))
                # Shift polynomials to compute the next degree
            old_loc = old_loc + [0]

                # Iteratively estimate the errata locator and evaluator polynomials
            if delta != 0:  # Update only if there's a discrepancy
                if len(old_loc) > len(err_loc):  # Rule B (rule A is implicitly defined because rule A just says that we skip any modification for this iteration)
                    new_loc = self.field.gf_poly_scale(old_loc, delta)
                    old_loc = self.field.gf_poly_scale(err_loc, self.field.gf_inverse(delta))  # effectively we are doing err_loc * 1/delta = err_loc // delta
                    err_loc = new_loc
                        # Update the update flag
                        # L = K - L # the update flag L is tricky: in Blahut's schema, it's mandatory to use `L = K - L - erase_count` (and indeed in a previous draft of this function, if you forgot to do `- erase_count` it would lead to correcting only 2*(errors+erasures) <= (n-k) instead of 2*errors+erasures <= (n-k)), but in this latest draft, this will lead to a wrong decoding in some cases where it should correctly decode! Thus you should try with and without `- erase_count` to update L on your own implementation and see which one works OK without producing wrong decoding failures.

                    # Update with the discrepancy
                err_loc = self.field.gf_poly_add(err_loc, self.field.gf_poly_scale(old_loc, delta))
                print ("BM err_loc " + str(err_loc))
        return err_loc


        #omega = self.field.gf_poly_div(self.field.gf_poly_mult(syndromes[::-1], err_loc), ([1] + [0] * (len(err_loc))))


    def find_error_locations(self, sigma):
        """
        Find error locations using Chien search

        Args:
        sigma (list): Error locator polynomial

        Returns:
        list: Error locations
        """
        error_locations = []

        eval_poly = 0
        err_loc =sigma

        for i in range(self.n):
            # Evaluate error locator polynomial
            eval_poly = self.field.gf_poly_eval(err_loc,self.field.gf_pow(2,i))

            if eval_poly == 0:
                error_locations.append(self.n - i)

        return error_locations

    def rs_find_errata_locator(self,e_pos):
        '''Compute the erasures/errors/errata locator polynomial from the erasures/errors/errata positions
           (the positions must be relative to the x coefficient, eg: "hello worldxxxxxxxxx" is tampered to "h_ll_ worldxxxxxxxxx"
           with xxxxxxxxx being the ecc of length n-k=9, here the string positions are [1, 4], but the coefficients are reversed
           since the ecc characters are placed as the first coefficients of the polynomial, thus the coefficients of the
           erased characters are n-1 - [1, 4] = [18, 15] = erasures_loc to be specified as an argument.'''

        e_loc = [1]
        for i in e_pos:
            #print (str(i))
            #print("pow " + str([self.field.gf_pow(2, i), 0]))
            #print("add " + str(self.field.gf_poly_add([1],[self.field.gf_pow(2, i), 0])))

            e_loc = self.field.gf_poly_mult(e_loc, self.field.gf_poly_add([1], [self.field.gf_pow(2, i), 0]))
            #print ("new eloc" + str(e_loc))
        return e_loc


    def rs_find_error_evaluator(self,synd, err_loc, nsym):
        '''Compute the error (or erasures if you supply sigma=erasures locator polynomial, or errata) evaluator polynomial Omega
           from the syndrome and the error/erasures/errata locator Sigma.'''

        remainder = self.field.gf_poly_mult(synd, err_loc)  # first multiply the syndromes with the errata locator polynomial
        remainder = remainder[len(remainder) - (nsym + 1):]

        return remainder

    def compute_error_magnitudes2(self, synd, error_locations,omega):
        """
        [IB] foreny without omega compute(is done in BM2)
        Compute error magnitudes using Forney algorithm

        Args:
        syndrome (list): syndrome polynomial
        error_locations (list): Error locations

        Returns:
        list: Error magnitudes
        """

        coef_pos = [(197 - p) for p in error_locations]
        err_eval = [0] + omega #BMA
        #err_eval = [0]*4 + omega #RiBM
        print("error eval ,omega ", err_eval)
        # Second part of Chien search to get the error location polynomial X from the error positions in err_pos (the roots of the error locator polynomial, ie, where it evaluates to 0)
        X = []  # will store the position of the errors
        X1 = []
        for i in range(0, len(coef_pos)):
            l = coef_pos[i]
            X.append(self.field.gf_pow(2, l))
        print("X ", X)

        # Forney algorithm: compute the magnitudes
        E = [0] * (3)
        Xlength = len(X)
        for i, Xi in enumerate(X):
            Xi_inv = self.field.gf_inverse(Xi)
            print("X_inv ", Xi_inv)
            # Compute the formal derivative of the error locator polynomial (see Blahut, Algebraic codes for data transmission, pp 196-197).
            # the formal derivative of the errata locator is used as the denominator of the Forney Algorithm, which simply says that the ith error value is given by error_evaluator(gf_inverse(Xi)) / error_locator_derivative(gf_inverse(Xi)). See Blahut, Algebraic codes for data transmission, pp 196-197.

            err_loc_prime = 1
            for j in xrange(Xlength): # deriv
                if j != i:
                    err_loc_prime = self.field.gf_mult(err_loc_prime, self.field.gf_add(1, self.field.gf_mult(Xi_inv, X[j])))

            y = self.field.gf_mult(Xi, self.field.gf_poly_eval(err_eval[::-1], Xi_inv))

            # Compute the magnitude
            error_magnitudes = self.field.gf_div(y, err_loc_prime)
            E[i] = error_magnitudes
        return E

    def compute_error_magnitudes3(self,  err_pos, sigma, omega):
        """
        [IB] more effective way to do Foreny,generated by CG
        Compute error magnitudes using Forney's Algorithm.

        Parameters:
        - syndromes: the list of syndromes [S1, ..., S2t]
        - err_pos: positions (indices) of the errors in the message
        - sigma: error locator polynomial
        - omega: error evaluator polynomial
        - n: total codeword length

        Returns:
        - List of error magnitudes (same length/order as err_pos)
        """
        err_magnitudes = []

        # Compute formal derivative of sigma(x)


        corrected_omega =  [0] + omega

        for loc in err_pos:
            # Convert position to root
            # power of 2 suppose to be negative exp, replace it by adding inverse

            #Xi = self.field.gf_inverse(self.field.gf_pow(2, -(255 - (197 - loc))))

            #Xi = self.field.gf_pow(2, 255 - loc)
            Xi = self.field.gf_pow(2, loc)
            # Evaluate omega at Xi
            omega_val = self.field.gf_poly_eval((corrected_omega[::-1]), Xi)

            # Compute sigma' (formal derivative)
            sigma_deriv = 0
            for j in range(1, len(sigma)):
                if j % 2 == 1: #odd values of sigma
                    term = self.field.gf_mult(sigma[j], self.field.gf_pow(Xi, j - 1))
                    sigma_deriv = self.field.gf_add(sigma_deriv, term)


            Xi_mult = self.field.gf_mult(Xi, omega_val)

            #magnitude = self.field.gf_div(Xi_mult, sigma_deriv)  # with X_i
            magnitude = self.field.gf_div(omega_val, sigma_deriv)  # without X_i

            err_magnitudes.append(magnitude)

        #print("foreny3 error_mag " + str(err_magnitudes) )
        #return err_magnitudes

    def compute_error_magnitudes(self, synd, error_locations):
        """
        Compute error magnitudes using Forney algorithm

        Args:
        syndrome (list): syndrome polynomial
        error_locations (list): Error locations

        Returns:
        list: Error magnitudes
        """

        coef_pos = [(197 - p) for p in error_locations]
        err_loc = self.rs_find_errata_locator(coef_pos) #error location polynomial, used only for omega calculations
        err_eval = (self.rs_find_error_evaluator(synd[::-1], err_loc, len(err_loc) - 1))[::-1] #omega
        print("error loc polynomial", err_loc)
        print("error eval ,omega ",err_eval)
        #print("coef " , coef_pos)
        # Second part of Chien search to get the error location polynomial X from the error positions in err_pos (the roots of the error locator polynomial, ie, where it evaluates to 0)
        X = []  # will store the position of the errors
        for i in range(0, len(coef_pos)):
            l = 255 - coef_pos[i]
            #print ("l", l)
            X.append(self.field.gf_inverse(self.field.gf_pow(2, l)))
            #X.append(self.field.gf_pow(2, -l))
        #print("X ", X)

        # Forney algorithm: compute the magnitudes
        E = [0] * (3)
        Xlength = len(X)
        for i, Xi in enumerate(X):
            Xi_inv = self.field.gf_inverse(Xi)

            # Compute the formal derivative of the error locator polynomial (see Blahut, Algebraic codes for data transmission, pp 196-197).
            # the formal derivative of the errata locator is used as the denominator of the Forney Algorithm, which simply says that the ith error value is given by error_evaluator(gf_inverse(Xi)) / error_locator_derivative(gf_inverse(Xi)). See Blahut, Algebraic codes for data transmission, pp 196-197.

            err_loc_prime = 1
            for j in xrange(Xlength):
                if j != i:
                    err_loc_prime = self.field.gf_mult(err_loc_prime, self.field.gf_add(1, self.field.gf_mult(Xi_inv, X[j])))
            y = self.field.gf_poly_eval(err_eval[::-1], Xi_inv)  # numerator of the Forney algorithm (errata evaluator evaluated)
            y = self.field.gf_mult(self.field.gf_pow(Xi, 1), y)


            # Compute the magnitude
            error_magnitudes = self.field.gf_div(y, err_loc_prime)
            E[i] = error_magnitudes
        return E


    def decode(self, received_msg):
        """
        Decode Reed-Solomon encoded message

        Args:
        received_msg (list): Received message

        Returns:
        tuple: Decoded message and error information
        """
        # Calculate syndromes
        syndromes = self.calculate_syndromes(received_msg)
        print('Syndromes (should be all zeros):', syndromes)

        # Check if all syndromes are zero (no errors)
        if all(s == 0 for s in syndromes):
            return received_msg[:self.k], []

        # Run Berlekamp-Massey algorithm
        sigma = self.berlekamp_massey(syndromes)
        omega = []
        print('Sigma :', sigma)

        # Run Berlekamp-Massey2 algorithm
        new_synd = syndromes
        print ("Run Berlekamp-Massey2 algorithm with synd "+str(new_synd))

        #print(self.berlekamp_massey2(syndromes[1:]))
        sigma2,omega2 = self.berlekamp_massey2(syndromes[1:])
        #sigma3, omega3 = self.ribm(syndromes[1:])
        sigma3, omega3 = self.ribm2(syndromes[1:])
        print("RiBM omega3 and sigma3")
        print (sigma3)
        print (omega3)


        scale_factor = sigma3[1]
        sigma4 = [self.field.gf_div(c, scale_factor) for c in sigma3]
        omega4 = [self.field.gf_div(c, scale_factor) for c in omega3]
        print("scale_factor ")
        print(scale_factor)
        print("RiBM omega4 and sigma4 ")
        print (sigma4)
        print (omega4)


        # Find error locations
        #error_positions = self.find_error_locations(sigma)
        error_positions = self.find_error_locations(sigma2)
        print('error_positions :', error_positions)

        # Compute error magnitudes
        #error_magnitudes = self.compute_error_magnitudes(syndromes,  error_positions)
        error_magnitudes = self.compute_error_magnitudes2(syndromes, error_positions, omega2)
        print('error_magnitudes :', error_magnitudes)


        self.compute_error_magnitudes3(error_positions, sigma, (omega2))

        #corrected_msg = received_msg
        #for k in error_positions:
        #    corrected_msg[error_positions] =

        return error_magnitudes


# Example usage
def test_reed_solomon():
    # Initialize Galois Field
    field = ReedSolomonGF(prim_poly=0x11D)

    pow_table = []
    inv_table = []
    #for i in range(256):
    #    pow_table.append(field.gf_pow(2,i))
    #    inv_table.append(field.gf_inverse(i))
    #print("pow and inv LUT")
    #print (pow_table)
    #print (inv_table)
    # Reed-Solomon parameters
    n = 197  # Total codeword length
    k = 193  # Message length
    t = 2  # Error-correction capability (4 parity bytes)

    # Create Reed-Solomon decoder
    rs = ReedSolomon(field, n, k, t)

    #first block
    # Create the message with error
    new_message = [0] * 198
    #new_message[22] = 1
    #new_message[23] = 3
    new_message[188] = 1
    new_message[189] = 0
    new_message[190] = 0
    new_message[191] = 1
    #new_message[191] = 2
    new_message[192] = 3
    #new_message[192] = 10
    new_message[193] = 51
    new_message[194] = 229
    new_message[195] = 109
    new_message[196] = 52
    new_message[197] = 141


    #second block
    new_message2 = [0] * 198
    for i in range(48):
        new_message2[i*4] = 16
        new_message2[i*4+1] = 128
        new_message2[i*4+2] = 0
        new_message2[i*4+3] = 136

    new_message2[192] = 3
    new_message2[193] = 51
    new_message2[194] = 162
    new_message2[195] = 243
    new_message2[196] = 190
    new_message2[197] = 223

    #print("new_message2")
    #print (new_message2)
    # Decode the message
    errors = rs.decode(new_message)
    print("\nOriginal Message:", new_message)

    print("Errors:", errors)


    #print ("gf inverse table")
    #for i in range(1,256):
    #    print("8'd" + str(i) + ": value = 8'd" + str(field.gf_inverse(i)) + ";")
    '''
    print (field.gf_mult_no_lut(92, 54))
    import random
    for i in range(1000):
        a = random.randint(10, 255)
        b = random.randint(10, 255)
        if field.gf_mult(a, b) != field.gf_mult_no_lut(a, b):
            print(str(field.gf_mult(a, b)) + " " + str(field.gf_mult_no_lut(a, b)) + " is not equal")
        else:
            #print(str(field.gf_mult(a, b)) + " " + str(field.gf_mult_no_lut(a, b)) + " is  equal")
            continue
        #print(str(field.gf_mult(50, 50)))
        #print(str(field.gf_mult_no_lut(50, 50)))
    '''
# Call the test function
test_reed_solomon()



